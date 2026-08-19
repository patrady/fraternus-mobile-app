# Fraternus Mobile App

A Flutter application for [Fraternus](https://fraternus.net), a Catholic brotherhood program that mentors young men (Brothers) through adult leaders (Captains) at weekly chapter meetings ("Frat Night"). Available free on iOS and Android.

## What is this?

The app is the day-to-day tool chapter members use between and during meetings. It supports two types of users: **Captains** (adult mentors/leaders) and **Guardians** (parents of Brothers, who may or may not be Captains themselves). It provides:

- **Field Guide** — Daily devotionals organized by weekly virtue themes, with identity readings, wisdom quotes, a daily challenge (Sword), a reflection (Spade), and a closing prayer. Tracks consecutive-day streaks.
- **Challenges** — Weekly challenges assigned at Frat Night. Captains and Guardians can track reps on behalf of Brothers. Tracks consecutive-week streaks.
- **Events** — Frat Nights, Excursions, Ranch (Summer Camp), HAWC Nights, and other chapter events. Supports RSVPs and calendar integration.
- **Profile** — Account management for Captains and Guardians, including Brother member records and COPPA-compliant consent tracking for members under 13.

Authentication and data are backed by [Supabase](https://supabase.com) (Postgres + Auth + PostgREST + Edge Functions). See [Architecture & Decisions](#architecture--decisions) below for why, and for the full domain/data model see [`docs/app_concept.md`](docs/app_concept.md).

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- [Dart SDK](https://dart.dev/get-dart) (bundled with Flutter)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development, macOS only)
- [Android Studio](https://developer.android.com/studio) with Android SDK (for Android development)
- [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started) (for running a local Supabase stack) and [Docker](https://docs.docker.com/get-docker/) (required by the Supabase CLI)

Verify your Flutter environment:

```bash
flutter doctor
```

## Installing Dependencies

```bash
flutter pub get
```

## Local Supabase Setup

Start the local Supabase stack (requires Docker running). On first run this also creates the local Postgres database and applies every migration in `supabase/migrations/`:

```bash
supabase start
```

Copy `fraternus_mobile_app/env/local.example.json` to `fraternus_mobile_app/env/local.json` and fill in the values `supabase start` (or `supabase status`) prints out:

```bash
cp fraternus_mobile_app/env/local.example.json fraternus_mobile_app/env/local.json
```

- `SUPABASE_URL` → the `API URL` value (`http://127.0.0.1:54321`)
- `SUPABASE_ANON_KEY` → the **`Publishable key`** value (starts with `sb_publishable_...`) — not the older JWT-looking `Anon key` that's also printed. Either authenticates fine, but `sb_publishable_...` is the format this app is built and tested against.

`env/local.json` is gitignored — each developer keeps their own copy.

### Applying new migrations

`supabase start` only bootstraps the schema the *first* time (when no local database volume exists yet). After pulling changes that add new files to `supabase/migrations/`, rebuild the schema from scratch with:

```bash
supabase db reset
```

This drops and recreates the local database, re-applies every migration in order, and re-runs `supabase/seed.sql` if one exists. It's the standard "pull latest, reset" command — safe to run any time you want a clean slate.

### Push notifications aren't wired up locally yet

Reminder notifications (Field Guide, Challenge, Event) require a Firebase project for FCM delivery, which isn't part of this local setup — cancelling an event or hitting a reminder's trigger condition won't produce a push locally. See [`SUPABASE_MIGRATION_TODO.md`](SUPABASE_MIGRATION_TODO.md) for the full status and setup steps.

### Seeding test data

The migrations currently seed only reference data with no admin UI to manage it yet: Chapters (`20260818180002_seed_chapters.sql`) and Frat Night Virtues (`20260818180000_seed_frat_night_virtues.sql`). A fresh local stack has **no** Field Guide weeks/devotionals, Frat Night Templates, Challenges, or Events — so right after signing up, Guide/Challenge/Events will correctly show their empty states ("Nothing to read for this date yet.", etc.) rather than a bug. To exercise those features locally, insert rows yourself via Supabase Studio's SQL editor or `psql` — see the table shapes in [`docs/app_concept.md`](docs/app_concept.md)'s Data Models section, or the `insert into` statements in the seed migrations above for the pattern.

### Viewing the Database

**Supabase Studio (GUI):** with the stack running, open [http://127.0.0.1:54323](http://127.0.0.1:54323) for a table browser and SQL editor.

**psql:**

```bash
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres"
```

## Running the App

All run commands must pass the env file via `--dart-define-from-file` so the app can reach Supabase:

**iOS Simulator:**

```bash
flutter run -d ios --dart-define-from-file=env/local.json
```

**Android Emulator:**

```bash
flutter run -d android --dart-define-from-file=env/local.json
```

**List available devices:**

```bash
flutter devices
```

**Run on a specific device:**

```bash
flutter run -d <device-id> --dart-define-from-file=env/local.json
```

## Running Tests

```bash
flutter test
```

## Running Widgetbook (Design System Catalog)

The design system's component catalog lives in a separate Flutter app at `fraternus_mobile_app/widgetbook`, which depends on `fraternus_mobile_app` via a path dependency. Keeping it separate means Widgetbook and `build_runner` never end up in the production app's dependency tree.

```bash
cd fraternus_mobile_app/widgetbook
flutter pub get
flutter pub run build_runner build -d
flutter run -t lib/main.dart -d chrome
```

Use `build_runner watch` instead of `build` while you're actively adding or editing use cases — it regenerates `lib/main.directories.g.dart` automatically on save, so you just need to hot reload (`r`) in the `flutter run` terminal to pick it up:

```bash
flutter pub run build_runner watch -d
```

New use cases (`@widgetbook.UseCase`) belong in `widgetbook/lib/design_system/...`, mirroring the folder structure of the component they document in `fraternus_mobile_app/lib/design_system/...` — not next to the component itself.

## Architecture & Decisions

Each feature (`fraternus_mobile_app/lib/features/{challenge,events,guide,profile,today}/`) follows the same shape: an abstract `XRepository` interface with a `SupabaseXRepository` implementation, wired through `@riverpod` providers, consumed by `ConsumerWidget` screens. Row Level Security in Postgres — not the Flutter code — is the actual authorization boundary; the anon key is safe to ship in the client for that reason.

The reasoning behind the current architecture, and what came before it, is written up as a series of ADRs (Architecture Decision Records) — read them in order for the full history:

- [ADR 0001](docs/adrs/001_initial_archectural_decisions.md) — the original on-device-only design (Drift for local storage, Auth0 for identity, no backend at all). Largely superseded by ADR 0002, but still the record of *why* those original choices were made.
- [ADR 0002](docs/adrs/002_supabase_backend_poc.md) — the decision to introduce a real backend and replace Auth0/on-device storage with Supabase. This is the architecture the app runs on today.
- [ADR 0003](docs/adrs/003_coppa_child_data_deletion.md) — how a Guardian's COPPA-mandated request to delete a child's data is implemented (cascading deletes rooted at the `Member` row).

[`SUPABASE_MIGRATION_TODO.md`](SUPABASE_MIGRATION_TODO.md) (repo root) tracks the live, phase-by-phase status of the Supabase migration described in ADR 0002 — what's done, what's blocked and on what, and known gaps. Check it before assuming a feature's backend is finished.

## Contributing

### Branching

- Branch off `main` for all work.
- Use descriptive branch names: `feature/field-guide-streak`, `fix/challenge-rsvp-constraint`, etc.

### Development workflow

1. Fork the repo and create your branch from `main`.
2. Install deps: `flutter pub get`
3. Make your changes and ensure `flutter analyze` passes with no issues.
4. Run tests: `flutter test`
5. Open a pull request against `main` with a clear description of what changed and why.

Generated files (`*.g.dart`, from `@riverpod` providers) are committed to the repo, so a fresh clone doesn't need a code-gen step to build. If you add or edit a `@riverpod` provider, regenerate them before committing:

```bash
cd fraternus_mobile_app
dart run build_runner build --delete-conflicting-outputs
```

### Code style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style).
- Run `dart format .` before committing.
- Keep `flutter analyze` clean — no warnings or errors.

### Key domain concepts

- A **User** is anyone with a login. A **Member** is someone registered with Fraternus (Brother, Captain, or Commander).
- A **User Member Association** links a User to a Member as either `Self` or `Guardian`.
- Brothers under 13 require COPPA-compliant guardian consent before any data is recorded on their behalf.
- Timezones are inferred from the member's chapter location.
- Content (Frat Night Templates, Field Guide entries, Events) is seeded directly into the database — there is no admin UI yet.

For deeper context on data models, business logic, and feature specifications, see [`docs/app_concept.md`](docs/app_concept.md).
