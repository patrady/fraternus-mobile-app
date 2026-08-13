# ADR 0001: Client architecture foundations for the Fraternus Flutter app

**Status:** Accepted
**Date:** 2026-07-25

## Context

Fraternus is a free Flutter app (iOS + Google Play) built around Auth0 authentication, with Users creating Member records for themselves (Captain) or their children (Brother, via Guardian relationship). The domain is relational: Field Guide devotionals, weekly Challenges, and Events all reference Chapter-scoped content and track per-Member completion data. This ADR captures the client-side architecture decisions made while scoping the app, before implementation begins.

---

## 1. State management: Riverpod

**Decision:** Use Riverpod 3.x with code generation (`@riverpod`) as the state management approach for the whole app.

**Rejected alternatives:**
- Provider — superseded by Riverpod; no reason to start a new project on it.
- Bloc — the event/state ceremony pays for itself on large teams needing a strict audit trail (e.g. fintech); not justified here.
- GetX — discouraged for new projects; declining community support.

**Rationale:** Riverpod providers aren't tied to `BuildContext`, and `AsyncValue` gives loading/data/error handling out of the box — the closest Flutter equivalent to a React Context + hooks + query-cache combination, which shortens the learning curve coming from React. It also composes cleanly with Drift's reactive `Stream` queries (see #3).

**Consequences:** Adds a `build_runner` code-gen step to the dev loop (`flutter pub run build_runner watch`).

---

## 2. Navigation: go_router

**Decision:** Use `go_router` with `StatefulShellRoute.indexedStack` for the four bottom-nav tabs (Field Guide, Challenges, Events, Profile).

**Rationale:** Official Flutter-recommended router; `StatefulShellRoute` preserves each tab's own navigation stack when switching away and back, matching typical bottom-nav UX expectations.

---

## 3. Backend & persistence: no server for now — Drift is the system of record

> **Superseded by [ADR 0002](./002_supabase_backend_poc.md) §3.** A Supabase backend is now being introduced (POC phase); Postgres becomes the system of record for user-generated data and Drift's role shifts to local cache, as anticipated in the "Revisit if" note below.

**Decision:** There is no custom backend for this phase of the project. No application server, no REST API, no database beyond what lives on the device. Auth0 remains the identity provider (see #6), but Drift (SQL-backed, type-safe, actively maintained) is the single, permanent store for **all** data — both reference content and user-generated data — until a backend is introduced.

**Rejected alternatives for the local database:** Isar and original Hive — both effectively unmaintained by their original authors; only community forks remain.

This supersedes the earlier draft of this ADR, which had Drift acting as a synced cache in front of a backend. The plan:

| Data | Plan |
|---|---|
| Chapter, Chapter Field Guide Details, Frat Night Template, Frat Night Virtue, Challenge, Field Guide Week (+ Quotes), Field Guide Daily Devotional, Event + detail tables, Event Attendees tables | Bundled with the app as seed data (e.g. JSON/SQL asset), loaded into Drift on first run and on app update |
| Chapter dropdown list | Hardcoded — this is now the long-term shape, not a temporary shortcut |
| Field Guide Daily Devotional Member, Challenge Member, Challenge Member Rep, Event RSVP, consent fields on User Member Association | Written locally and stay there — no push queue, no sync worker |

**Consequences:**
- New or changed content (a new Field Guide week, a new Frat Night template, a new Event, a Frat Night cancellation) only reaches devices via an app store release that ships updated bundled seed data — there is no live content channel. A cancelled Frat Night, for example, won't be reflected on-device until the user updates the app.
- No cross-device continuity: a Guardian using the app on two devices sees two independent datasets, since nothing syncs between them.
- No reinstall protection beyond what the OS provides: iOS iCloud backup / Android backup can preserve the local database as part of a full device backup and restore, but there's no dedicated recovery path if that's disabled, or if a user switches platforms (iOS ↔ Android).
- Simpler to build for now: no sync worker, no push queue, no conflict resolution, no server to stand up or operate.

**Revisit if:** a backend is introduced later. At that point, reference content moves back to a pull-sync model and user-generated data moves back to a push queue, largely as scoped in the original draft of this decision — Drift's role shifts from system of record to local cache + offline write buffer.

---

## 4. Calendar export: add_2_calendar

**Decision:** Use `add_2_calendar` for "add this event to my device calendar."

**Rejected alternative:** `device_calendar` — provides full read/write calendar access, which is more than this feature (one-way export only) requires.

---

## 5. Notifications: fully on-device scheduling (no server push for v1)

> **Partially reopened by [ADR 0002](./002_supabase_backend_poc.md) §7.** A server push channel now exists (Supabase `pg_cron` + Edge Function + FCM), which was the specific blocker cited below for event-cancellation alerts. Reconciling server-triggered reminders with this on-device scheduler is deferred to a follow-up ADR.

**Decision:** All notifications are scheduled and delivered on-device via `flutter_local_notifications` + `timezone`, computed entirely from locally cached Drift data. No FCM or server-triggered push in v1.

**Mechanism:** A reconciliation routine runs (a) on app resume and (b) after any local write that could affect the schedule (accepting a challenge, completing a rep, completing a devotional, changing an RSVP). Each run cancels all pending local notifications and reschedules a fresh set from a rolling ~14-day lookahead window over current local data — no per-notification ID tracking needed.

**Per-type computation:**
- **Field guide 7am/8pm reminders** — computed from the school-year/week/day algorithm against locally cached `Chapter Field Guide Details` and `Field Guide Daily Devotional`; only scheduled for dates where a devotional actually exists.
- **Challenge intro / mid-week / day-before reminders** — keyed off the chapter's Frat Night day of week and `Challenge Member` data; mid-week and day-before reminders are cancelled as soon as all reps are marked complete (as a side effect of that write triggering reconciliation).
- **Event 24hr/1hr reminders** — scheduled directly from cached `Event.Start Date` for events the member has RSVP'd to; dropped automatically if a cancellation syncs down before the reminder fires.
- **Per-user, not per-Member, deduping** — notifications are keyed by `(User Id, notification type, date)`, with generic copy, so a Captain or Guardian with multiple children gets one notification per type per day, not one per child.

**Tradeoff explicitly accepted:** Event cancellation alerts (spec requirement: notify all eligible attendees when an event is cancelled, regardless of RSVP) are **not implemented in v1**. A proactive interrupt-style alert independent of app state inherently requires a server push channel, which this ADR defers. Reconciliation will still quietly drop reminders for a cancelled event once the cancellation syncs locally, so no misleading "starts in 1 hour" notifications will fire — there's just no proactive "this was cancelled" push.

**Platform constraints:**
- iOS caps pending local notifications at 64 total — informs the bounded ~14-day lookahead window.
- Android 12+ requires the user-grantable "Alarms & reminders" (`SCHEDULE_EXACT_ALARM`) permission for exact-time delivery; falls back to `AndroidScheduleMode.inexact` if denied.

**Follow-on schema change:** Add a `Time Zone` (IANA identifier, e.g. `America/New_York`) field to `Chapter`, set at seed time, rather than deriving timezone from City/State/Zip at runtime.

**Revisit if:** Event-cancellation alerts become a priority — at that point, introduce FCM + `flutter_local_notifications` for that specific case only; the rest of the notification system can remain fully local.

---

## 6. Authentication: Auth0 official SDK (fully on-device, no backend required)

> **Superseded by [ADR 0002](./002_supabase_backend_poc.md) §2.** Auth0 is replaced by Supabase Auth as part of introducing a backend; no production users existed at the time of the switch, so no migration was required.

**Decision:** `auth0_flutter` for the OAuth flow, paired with `flutter_secure_storage` for token storage (keychain/keystore-backed).

**Compatibility with decision #3 (no backend):** Auth0 is itself a hosted identity provider, so every authentication flow runs without Fraternus operating any server:
- Username/password and passkey login run through Auth0's hosted Universal Login, driven entirely by the SDK from the device.
- Forgot-password and confirm-email flows are handled by Auth0's own hosted pages and email delivery — no custom backend endpoint needed.
- Signup fields (first name, last name, email) can be captured via Auth0's public signup endpoint (`/dbconnections/signup`), which accepts `user_metadata` using only the public client ID — no client secret required, so it's safe to call directly from the app.

**Known limitation:** the Auth0 Management API (bulk user administration, updating another user's profile outside of login, custom role/claim assignment) requires a confidential client with a client secret, which must never be embedded in a mobile app. That part of Auth0 does need a backend (or a small serverless function) to use safely. Fraternus doesn't need it today: Auth0 is scoped to identity only (who's logged in), while all actual domain data — Member records, chapter assignment, consent status, challenge/devotional history — lives in Drift, not in Auth0 user/app metadata. As long as that boundary holds, Auth0 stays fully compatible with the no-backend decision in #3.

---

## 7. Design system: Material 3 defaults

**Decision:** Start from Flutter's default Material 3 theming with a custom `ColorScheme`/`ThemeData`, rather than building a bespoke design system up front. Restyle incrementally as the app's visual identity solidifies.