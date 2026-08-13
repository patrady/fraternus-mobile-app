# ADR 0002: Supabase as backend (POC)

**Status:** Accepted — POC phase
**Date:** 2026-08-12

## Context

ADR 0001 §3 deliberately shipped v1 with no backend, Drift as the sole system of record, and explicitly scoped a return path: *"Revisit if a backend is introduced later. At that point, reference content moves back to a pull-sync model and user-generated data moves back to a push queue... Drift's role shifts from system of record to local cache."* ADR 0001 §5 similarly deferred event-cancellation push alerts specifically because no server push channel existed.

We're now introducing that backend. Requirements: authentication, CRUD for user-generated data (Member records, challenge/devotional completion, event RSVPs), and server-triggered reminders — including the event-cancellation gap ADR 0001 §5 deferred. Team size is 1-2 developers, indefinitely, which biases every decision below toward minimizing ongoing operational burden over maximizing flexibility.

This ADR supersedes ADR 0001 §3 and §6, and partially reopens §5.

---

## 1. Backend platform: Supabase

**Decision:** Adopt Supabase (hosted Postgres + Auth + Realtime + Edge Functions) as the backend for the POC.

**Rejected alternatives:**
- **Firebase/Firestore** — NoSQL document model fights the domain, which is inherently relational (Guardian↔Member relationships, Chapter-scoped content, per-Member completion tracking across multiple content types).
- **Custom framework** (NestJS, FastAPI, Go) — full ownership of auth, migrations, and infrastructure isn't justified for this workload at this team size; more code to write and maintain forever for a 1-2 person team.
- **Pocketbase** — leaner self-hosted option, but smaller ecosystem, a SQLite ceiling, and still carries real (if smaller) ops burden — patching, backups, the VM itself.

**Rationale:** The domain's relational shape maps directly onto Postgres. Because it's Postgres underneath rather than a proprietary store, the data and schema stay portable (`pg_dump` to any Postgres host) even though the auth/CRUD/scheduling layers are Supabase-managed — this materially reduces how bad a future migration would be compared to Firestore. One platform covers all three requirements (auth, CRUD, scheduled server logic) without hand-rolling any of them.

**Consequences:** Introduces an external hosted dependency and recurring cost (free tier at POC scale; ~$25/mo Pro tier if it graduates past POC limits).

---

## 2. Authentication: Supabase Auth replaces Auth0 (supersedes ADR 0001 §6)

**Decision:** Use Supabase's built-in Auth (email/password now, OAuth providers as needed) instead of Auth0. Supabase issues and manages the JWTs that authorize every subsequent request.

**Rationale:** Consolidates auth and data behind a single platform and a single JWT model — RLS policies key directly off `auth.uid()` with no third-party-issuer trust configuration to set up and maintain. One less vendor relationship for a 1-2 person team to operate.

**Consequences:**
- The Auth0 integration work described in ADR 0001 §6 (`auth0_flutter`, Universal Login, `/dbconnections/signup`) is not carried forward into this POC.
- No production users exist yet, so there's no account-migration cost — this is a pre-launch swap, not a migration.
- Auth0's hosted forgot-password/email-confirmation flows are replaced by Supabase Auth's equivalent hosted flows (magic link, password reset emails). Functionally equivalent on paper; verifying this in practice is part of the POC.

---

## 3. System of record: Postgres for user-generated data; Drift's role shifts to cache (supersedes ADR 0001 §3)

**Decision:** User-generated data (Member records, Guardian relationships, challenge/devotional completion, event RSVPs, consent fields) now lives in Supabase Postgres as the source of truth. Drift's role shifts to local cache / offline-read buffer — exactly the shift ADR 0001 §3 anticipated.

**Explicitly deferred for POC scope:** A full offline write queue with conflict resolution is not being built yet. The POC assumes online-first behavior (write directly to Supabase, refetch on reconnect) rather than the push-queue mechanism ADR 0001 §3's original draft sketched. This keeps the POC's surface area small; revisit before any production rollout.

**Explicitly out of scope for this ADR:** Whether bundled reference content (Chapters, Field Guide content, Frat Night templates) also moves server-side. For the POC, reference content stays bundled with the app as-is — this ADR only moves user-generated data.

**Consequences:** Closes the cross-device continuity gap ADR 0001 §3 flagged as a limitation (a Guardian on two devices previously saw two independent datasets). Reopens the operational questions ADR 0001 §3 avoided by having no backend: schema migrations, backups, and uptime are now real concerns, even if Supabase manages the infrastructure itself.

---

## 4. Client integration: repository abstraction over the Supabase SDK

**Decision:** No UI or state-management code calls the Supabase client directly. Every resource gets a repository interface (e.g. `RemindersRepository`) with a Supabase-backed implementation, wired through Riverpod providers.

**Rationale:** Decouples call sites from Supabase's specific query shape. A future backend swap becomes "write a new implementation class and change one provider," not "find and rewrite every screen that touches this data."

**Consequences:** Small, constant boilerplate cost (one interface + one implementation per resource) — acceptable for a 2-person team, and cheap insurance against the lock-in concern raised during scoping.

---

## 5. Authorization model: Row Level Security (RLS)

**Decision:** Authorization — a user seeing only their own data, a Guardian seeing their Members' data — is enforced with Postgres RLS policies, not application-layer checks.

**Rationale:** Enforcement happens at the data layer regardless of call path (auto-generated CRUD, RPC, or Edge Function), which removes an entire class of "forgot to check permissions in this one endpoint" bugs. Maps naturally onto the existing Guardian/Member relational model.

**Consequences:** RLS policies (and any `security definer` helper functions used for relationship traversal, e.g. a Guardian-link check) are part of the schema and need the same review rigor as application code. If the backend is ever migrated off Postgres, this authorization logic has to be reimplemented as application code — real cost, but the same cost any backend migration would eventually incur, not something specific to choosing Supabase.

---

## 6. Custom (non-CRUD) endpoints: Postgres functions (RPC) by default, Edge Functions for external calls

**Decision:** Logic that's pure data manipulation with business-rule checks (e.g. "join a group via invite code") is a Postgres function called via `supabase.rpc(...)`. Logic that needs to leave Postgres (calling FCM, email providers, any third-party API) is a Deno Edge Function.

**Rationale:** RPC functions are transactional, have no cold start, and need no separate deploy pipeline — the cheaper default. Edge Functions are reserved for the cases that actually require them.

---

## 7. Server-triggered reminders (reopens ADR 0001 §5)

**Decision:** Reminders can now be computed and dispatched server-side — a `pg_cron` schedule triggering an Edge Function that queries due reminders and calls FCM — rather than exclusively on-device.

**Rationale:** ADR 0001 §5 named the exact reason event-cancellation alerts were deferred: *"a proactive interrupt-style alert independent of app state inherently requires a server push channel, which this ADR defers."* That channel now exists.

**Consequences:** Introduces FCM (`firebase_messaging`/FlutterFire on the Flutter side) purely as a push-delivery transport — unrelated to the earlier Firebase-as-backend option, which was rejected in §1. Once reminder-relevant data (challenges, devotionals, events) lives server-side per §3, on-device notification scheduling and server-triggered reminders would otherwise double-notify on the same events; reconciling or replacing ADR 0001 §5's on-device scheduler is real design work and is **out of scope for this ADR**. Treat it as a follow-up ADR once the POC validates the underlying data model.

---

## POC scope and success criteria

The POC needs to prove: sign-up/sign-in through Supabase Auth, one CRUD resource end-to-end (e.g. Field Guide Daily Devotional Member completion) governed by RLS, and one server-triggered reminder path (`pg_cron` → Edge Function → FCM) — before committing to further build-out.

**Explicitly out of scope for the POC:** full data-model migration, a rewritten notification system, RLS coverage for every table, production hosting/monitoring setup.

## Revisit if

- The POC surfaces a blocker specific to Supabase itself — RLS complexity becoming unmanageable, Edge Function cold-start latency unacceptable for time-sensitive reminders, or pricing that doesn't hold up past POC scale — at which point the Firebase/custom-backend alternatives evaluated in §1 are the fallback options to reconsider.
- The domain needs something Postgres + RLS doesn't fit well (heavy custom compute, genuinely non-relational data).
