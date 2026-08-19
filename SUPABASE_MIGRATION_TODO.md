# Supabase Migration — Remaining Work

Tracks what's left in the Supabase backend migration (see `docs/adrs/002_supabase_backend_poc.md` and `docs/adrs/003_coppa_child_data_deletion.md` for the decisions behind this work). Update this as phases complete — delete it once the migration is fully done and its content has been folded into the ADRs / README.

## Status as of Phase 7

Phases 1–7 done and verified against a real local Supabase stack (Docker/OrbStack): project scaffolding, real Supabase Auth, Field Guide as the CRUD+RLS vertical slice, the event-cancellation server-push pipeline (verified to the FCM credentials boundary), full Profile completion, Challenges (accept/toggle-rep/current-challenge-resolution), and now Events (full feature): `SupabaseEventsRepository`, the client-scoped `get_event_eligible_members` RPC, `submit_event_rsvp`'s upsert/toggle-off RPC, and the `event_rsvps` DELETE policy the toggle-off needs. All three of ADR 0002's POC success criteria are met at the backend level. 24 widget tests pass, `flutter analyze` clean.

Phase 7 verification notes:
- Confirmed via curl+psql against the real stack: chapter-role eligibility (`chapter`/`captains`/`brothers`) resolves correctly per member role, `submit_event_rsvp` upserts, toggles off on re-selecting the same response, and updates in place on a different response; a stranger account gets `42501` trying to RSVP for a member they have no association with; PostgREST's nested embed returns the one-to-one detail tables (`event_frat_night_details`/`event_excursion_details`/`event_ranch_details`) as a single object (not an array) as expected, given the unique FK.
- Verified the real Events tab renders correctly against seeded real data on the iOS simulator (title/time/location/"IN 2 HOURS" badge all correct) after a full cold app reinstall — a stale `flutter run` session from earlier phase testing was still attached to an old in-memory Supabase session and showing fake-looking cached data at first, which is worth remembering next time a screenshot looks wrong: force `simctl terminate` + `simctl uninstall` before trusting what's on screen after a `db reset`. Interactive RSVP-tap-through in the simulator wasn't completed — blind AppleScript coordinate clicks into the simulator didn't reliably reach the text fields, and it wasn't worth more time given the RPC path is already proven directly against the API.
- "Others Attending" — confirmed with the user this is a real business rule, not something to invent: any authenticated user can see who else has accepted ("Going") an event, even if they haven't RSVP'd themselves; their own household is excluded (shown separately via the RSVP section). Implemented as `get_event_attendees(event_id)`, a `security definer` RPC returning just `member_id`/`first_name`/`last_name` for accepted, non-own-household members — same "cross-household read gets its own narrow RPC" pattern as `get_event_eligible_members`, rather than widening `event_rsvps`'/`members`' RLS (which would've required loosening `members`' own read policy just to resolve names through a nested embed). Verified via curl with two separate households: a user who hasn't RSVP'd still sees the other household's accepted attendee; tentative/declined responses don't appear; a household never sees itself in its own list.
- Fixed an unrelated pre-existing bug blocking `db reset` entirely: `supabase/migrations/20260818180001_frat_night_templates_virtue_key.sql` (an in-progress migration switching `frat_night_templates` to reference `frat_night_virtues` by a natural `key` instead of `id`) used a correlated subquery inside `ALTER COLUMN ... TYPE ... USING`, which Postgres rejects (SQLSTATE 0A000). Rewrote as add-column/populate-via-join/drop/rename.

Earlier real-stack bugs (Phases 5–6, for reference — keep testing every phase's actual write/read path against a live instance, not just stub data):
- Phase 5: a client-direct `INSERT` on `user_reminders`/`user_devices` that omits `user_id` sends `NULL`, and `with check (user_id = auth.uid())` evaluates `NULL = uuid` as `NULL` (not true) — same generic RLS-violation error a real cross-user attempt gets. Fixed with `default auth.uid()` on both tables.
- Phase 6: `has_challenge_member_association()` was used in policies before it was ever defined anywhere. Had to add it to the `challenges` migration itself (not the earlier `members_and_associations` migration) since it references `challenge_members`, which doesn't exist until then.

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
| ~~6~~ | ~~Challenges~~ — done | — |
| ~~7~~ | ~~Events (full feature)~~ — done | — |
| 8 | Today dashboard: compose client-side from the now-migrated Guide/Challenge/Events providers, remove `TodayDashboardRepository` | Phases 6, 7 — unblocked |
| 9 | Remaining 6 reminder types via `pg_cron` | Firebase project; **also needs its own follow-up ADR** resolving how server-triggered reminders coexist with ADR 0001 §5's still-live on-device `flutter_local_notifications` scheduler — explicitly deferred by ADR 0002 §7, not something to improvise mid-phase |
| 10 | Chapter dropdown off `seedChapters` — independent of everything else, could be pulled earlier | none |

## Cross-cutting follow-ups (not tied to one phase)

- **Derive household member lists/labels from real `Member` records.** Today/Guide still hardcode `'you'/'jack'/'thomas'` as literal member keys and display labels throughout the UI/provider layer (e.g. `guide_screen.dart`'s `_personLabels` map, `GuideSelectedPerson.build() => 'you'`). **Challenge and Events are now fixed** — `challengeHouseholdProvider`/`visibleEventsProvider` derive real ids and `member.firstName` labels from `householdMembersProvider` — but this drops the "You" special-casing the self Member used to get (a Guardian now sees their own first name instead of "You" on their own person-tab/RSVP row). Not fully fixed, just no longer worse than before; still needs the same treatment across Today/Guide, plus deciding whether "You" comes back for the self Member specifically.
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
