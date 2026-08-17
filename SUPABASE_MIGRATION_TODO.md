# Supabase Migration — Remaining Work

Tracks what's left in the Supabase backend migration (see `docs/adrs/002_supabase_backend_poc.md` and `docs/adrs/003_coppa_child_data_deletion.md` for the decisions behind this work). Update this as phases complete — delete it once the migration is fully done and its content has been folded into the ADRs / README.

## Status as of Phase 5

Phases 1–5 done and verified against a real local Supabase stack (Docker/OrbStack): project scaffolding, real Supabase Auth (sign-up/sign-in/sign-out, router auth-gate), Field Guide as the CRUD+RLS vertical slice, the event-cancellation server-push pipeline (verified correct all the way to the FCM credentials boundary), and full Profile completion (child creation/editing/deletion, consent revocation, the 7-type reminder system with a master switch, and the Captain/Guardian signup RPC wiring). All three of ADR 0002's POC success criteria are met at the backend level. 24 widget tests pass, `flutter analyze` clean.

Two more real bugs caught by testing Phase 5 against the real stack (same pattern as Phase 4's `service_role` grant finding — this keeps happening, worth remembering for every future phase): a client-direct `INSERT` on `user_reminders`/`user_devices` that omits `user_id` sends `NULL`, and `with check (user_id = auth.uid())` evaluates `NULL = uuid` as `NULL` (not true), so RLS rejects it with the same generic error a real cross-user attempt would get — fixed by giving `user_id` a `default auth.uid()` on both tables. **Any future table with a client-direct insert needs this same default, or the same silent trap is waiting.**

**Nothing from this work is committed to git yet.**

## Blocking external setup (not something I can do autonomously)

1. **Firebase project** — needed to actually deliver push notifications (Phase 4's cancellation pipeline is built and tested up to this point; Phase 9's remaining 6 reminder types need it too). Steps once you have one:
   - Enable Cloud Messaging.
   - Create a service account with the Firebase Cloud Messaging API role, download its JSON key.
   - iOS: upload an APNs auth key (Firebase Console → Project Settings → Cloud Messaging → Apple app config) — without this, iOS can't receive pushes at all, regardless of app code.
   - `supabase secrets set FCM_SERVICE_ACCOUNT_JSON='<json, one line>'`, `FCM_PROJECT_ID`, and `WEBHOOK_SECRET` (must match the value passed to `vault.create_secret('<value>', 'webhook_secret')` — see the events migration).
   - Add `firebase_core`/`firebase_messaging` to the Flutter app, wire `Firebase.initializeApp()`, build a device-token repository that upserts into `user_devices`. Deliberately not started yet — adding the dependency without real config files (`GoogleService-Info.plist`/`google-services.json`) risks breaking the native build in ways that can't be verified without them.

2. **Hosted Supabase project** — everything so far is local-only (`supabase start`). Before this ships:
   - Create the hosted project, `supabase link --project-ref <ref>`, `supabase db push`.
   - Run the one-time `select vault.create_secret(...)` webhook-secret setup against the hosted DB too (separate from local's).
   - Fill in `fraternus_mobile_app/env/prod.json` from `env/prod.example.json` with the hosted project's URL/anon key.
   - Deploy Edge Functions: `supabase functions deploy notify-event-cancellation`.

## Remaining phases

| Phase | What | Depends on |
|---|---|---|
| ~~5~~ | ~~Profile completion~~ — done | — |
| 6 | Challenges: migration for `challenges`/`challenge_members`/`challenge_member_reps`, `get_current_challenge`/`toggle_challenge_rep` RPCs, `SupabaseChallengeRepository` | none — next up |
| 7 | Events (full feature): `SupabaseEventsRepository`, `get_event_eligible_members` (client-scoped, distinct from Phase 4's `get_all_event_eligible_members`), `submit_event_rsvp` RPC — **also needs a DELETE RLS policy added to `event_rsvps`**, which was deliberately left out in Phase 4 since no delete path existed yet (see the comment in the events migration) | none |
| 8 | Today dashboard: compose client-side from the now-migrated Guide/Challenge/Events providers, remove `TodayDashboardRepository` | Phases 6, 7 |
| 9 | Remaining 6 reminder types via `pg_cron` | Firebase project; **also needs its own follow-up ADR** resolving how server-triggered reminders coexist with ADR 0001 §5's still-live on-device `flutter_local_notifications` scheduler — explicitly deferred by ADR 0002 §7, not something to improvise mid-phase |
| 10 | Chapter dropdown off `seedChapters` — independent of everything else, could be pulled earlier | none |

## Cross-cutting follow-ups (not tied to one phase)

- **Derive household member lists/labels from real `Member` records.** Today/Challenge/Guide/Events all hardcode `'you'/'jack'/'thomas'` as literal member keys and display labels throughout the UI/provider layer (e.g. `guide_screen.dart`'s `_personLabels` map, `GuideSelectedPerson.build() => 'you'`). Fine for static fake data, incompatible with real households of arbitrary size/names. Confirmed OK to do as its own pass rather than folded into a feature phase — but needs to happen before this migration is considered done.
- **Consent-granting verification flow.** Revocation is done (UI lives on Edit Child, tested against both the fake and — via the same RLS UPDATE policy exercised in Phase 4's pipeline test — the real stack). *Granting* consent plausibly needs a real verification mechanism (e.g. an emailed confirmation link hitting an Edge Function) — intentionally left undesigned, not just unbuilt. No UI or backend path exists for it yet.
- ~~`HouseholdAssociations.remove`~~ — done, removed; the whole class was simplified to a plain function provider since nothing mutates it directly anymore.
- **ADR 0002 §3 supersession note.** This work moved reference content (Chapters, Field Guide content, Frat Night templates, Events) into Postgres, which is broader than ADR 0002 §3's literal framing ("reference content stays bundled"). Worth a short note added to ADR 0002 itself acknowledging this, same pattern ADR 0002 used against ADR 0001 — not yet written.

## Known doc/spec bugs to fix (found during implementation, not yet corrected in the docs themselves)

- `docs/app_concept.md`'s Field Guide algorithm section says `Day Number = ... mod 7` (implying 0–6). The already-shipped Dart code and this migration's SQL both use 1–7, Monday-anchored (matching `DateTime.weekday`) — the doc prose has the bug, the code doesn't. Worth a one-line fix to the doc.
- `docs/app_concept.md`'s Profile section lists Captain signup fields as "first name, last name, email, and chapter" — no birthday — but the Member Data Model (and the already-built Dart model) require birthday for every role. The sign-up screens already collect it (fixed in Phase 2); the doc prose should be corrected to match.
- `README.md` (repo root) and its "An Auth0 tenant configured for this app" prerequisite still describe Auth0 as the auth provider — needs updating to Supabase now that ADR 0002 §2 superseded that decision.

## Local dev environment notes

- `supabase start` runs the full local stack via Docker/OrbStack; `fraternus_mobile_app/env/local.json` has real local credentials (gitignored — regenerate via `supabase status` if it's ever lost).
- Widgetbook has no use case yet for `FormTextField`'s `obscureText` parameter (added in Phase 2 for password fields).
