# ADR 0003: Parent-initiated deletion of a child's data (COPPA)

**Status:** Accepted
**Date:** 2026-08-12

> **Update 2026-09-04:** Birthday and COPPA consent tracking (the "COPPA/Consent" section this ADR's Context refers to, and the `Birthday`/`Consent Status`/`Consent Date`/`Consent Method` fields in the Data Model table below) have been removed from the app — this app now only supports parents managing their own account and their children's Member records directly, with no age-based gating. The deletion mechanism this ADR describes is **retained** as a general parent-initiated data-deletion right, independent of COPPA/age — its rationale in `## Scope` (applying uniformly regardless of a Brother's age, to avoid age-gating complexity) already argued for exactly this, so nothing about the deletion mechanics changes. The `delete_member_data` RPC and cascade-delete design below are unaffected; only the since-removed fields it used to delete are gone.

## Context

`app_concept.md`'s COPPA/Consent section already requires verifiable Guardian consent before a Brother under 13's Member record is usable, and lets a Guardian revoke consent at any time to stop *further* data collection. Revoking consent is not the same thing as deletion — it halts new writes but leaves everything already collected in place. COPPA separately requires that a parent be able to request deletion of a child's already-collected personal information, and this ADR defines what that means concretely against the data models in `app_concept.md`, and how it's implemented.

This is only implementable as a structural, database-enforced guarantee because [ADR 0002](./002_supabase_backend_poc.md) moved user-generated data into Supabase Postgres. Under ADR 0001's original no-backend design, this data lived only in on-device Drift — there was no way to reach a Guardian's other devices, and no single enforcement point to guarantee completeness.

## Scope

Applies to any Member with `Role = Brother`, invocable by any User holding a User Member Association to that Member with `Relationship = Guardian`. Applied uniformly regardless of the Brother's current age — not gated to strictly-under-13. Birthdays change, and a Guardian who created and manages a Member record has a reasonable claim to delete it regardless of whether that child happens to currently be under or over the COPPA age threshold; age-gating this would add complexity for a right that's simpler and safer to extend universally to parent-managed records.

---

## Decision 1: `Member` is the root of deletion; every dependent table cascades via FK constraint, not application code

**Decision:** Deleting a `Member` row is the single entry point. Every table that references a Member Id — directly, or indirectly through another child table — uses `ON DELETE CASCADE`. Completeness is a schema-level guarantee, not something that depends on an application-level list of "everywhere we need to remember to delete from."

**Rejected alternative:** A function that issues an explicit multi-table `DELETE` list. Rejected because its completeness depends on every future developer remembering to update that list whenever they add a new Member-referencing table — a missed table is a silent COPPA violation. A missing `ON DELETE CASCADE` is the same underlying risk, but it's visible at table-creation/schema-review time and is greppable across the schema, rather than buried in application logic that has to be kept in sync by hand.

## Decision 2: deletion is a Postgres RPC, not a raw client `DELETE`

**Decision:** Expose `delete_member_data(member_id uuid)` as a `security definer` Postgres function, following the RPC pattern established in [ADR 0002](./002_supabase_backend_poc.md) §6 — not a raw `DELETE` issued by the client through PostgREST.

**Rationale:** Centralizes the authorization check (the caller must hold a `Relationship = Guardian` association to that specific Member) in one reviewable place, rather than depending on RLS `DELETE` policies replicated correctly across every cascading table. This is defense in depth on top of decision 1: even if a cascade constraint were ever missing on a new table, the RPC's authorization gate is still the only door in.

## Decision 3: hard delete, not soft-delete or anonymization

**Decision:** Deletion is a real SQL `DELETE`, not a soft-delete flag or an anonymization pass.

**Rationale:** COPPA's deletion right means the data is gone, not hidden from normal queries while still sitting in the table for an admin to find.

**Consequences:**
- Irreversible — no undo once the RPC runs. The client-side confirmation step before calling this RPC is required but is a UX/product decision, out of scope for this ADR.
- Hard-deleting the `User Member Association` row also destroys the historical record that consent was ever granted or revoked for that Member. That's the intended effect of an erasure request, but it's worth Fraternus's counsel confirming there isn't a separate, narrower obligation to retain a minimal consent-history audit trail independent of the substantive data — noted here rather than decided, since that's a legal question, not an engineering one.

**Revisit if:** product/legal requirements call for a grace period (e.g., a 24–48 hour window to cancel an accidental request). That would mean adding a "pending deletion" state plus a scheduled job to finalize it — a reasonable enhancement, but not required to satisfy COPPA itself, so not built now.

---

## Data included, mapped against `app_concept.md`'s Data Models

| Table | Included in deletion? | Why |
|---|---|---|
| **Member** | Yes — root of the delete | The record itself: First Name, Last Name, Birthday, Chapter Id, Role. This is the core PII. |
| **User Member Association** | Yes — cascade | Rows where Member Id = this Brother, including Consent Status, Consent Date, Consent Method. |
| **Field Guide Daily Devotional Member** | Yes — cascade | Sword selection and the free-text Spade reflection — the most personal, user-authored content anywhere in the schema for a given day. |
| **Challenge Member** | Yes — cascade | Committed Date, Completed Date for this Member. |
| **Challenge Member Rep** | Yes — cascade (via Challenge Member Id) | Individual rep completions tied to this Member's Challenge Member rows. |
| **Event RSVP** | Yes — cascade | RSVP Response history for this Member. |
| **Event Attendees Specific** | Yes — cascade | Explicit individual-invite records naming this Member. |
| Chapter, Chapter Field Guide Details, Frat Night Template, Frat Night Virtue, Challenge, Field Guide Week (+ Quotes), Field Guide Daily Devotional, Event (+ Frat Night/Excursion/Ranch Details), Event Attendees Chapter | No | Shared reference/config content, not specific to any one child — contains no PII about the Brother. Deleting one Member must never affect this content for other Members. |
| User (the Guardian's own account), and any Self-Member/Captain record belonging to the Guardian | No | Out of scope — this ADR covers the child's data only, not the requesting Guardian's own account. |

---

## Open items / explicitly out of scope

- **Supabase Auth:** today a Brother has no `auth.users` row — per `app_concept.md`'s Profile section, "Brothers cannot sign up for their own account yet." There's nothing to delete on the Auth side yet. Once the future invite/claim flow ships (a Brother claiming their own account against an existing Member record), this ADR needs a follow-up: deleting a claimed Brother's Member data without also addressing their Auth account would leave an orphaned login with no Member record behind it.
- **Third-party subprocessors:** deletion covers Fraternus's own database. It does not retroactively unsend a push notification already delivered via FCM or an email already sent.
- **Audit logging of the deletion request itself** (who requested it, when) is a reasonable addition but not decided here.

## Revisit if

- The Brother-claims-own-account invite flow ships — extend this ADR (or write a follow-up) to cover the Auth-side account question noted above.
- Fraternus's counsel identifies a distinct retention obligation for consent history that's in tension with Decision 3's full hard delete.
