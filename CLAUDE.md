# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Flutter app for Fraternus, a Catholic brotherhood program that mentors young men ("Brothers") through adult leaders ("Captains") at weekly chapter meetings ("Frat Night"). Users are **Captains** and **Guardians** (parents, who may also be Captains). Four features: Field Guide (daily devotionals/streaks), Challenges (weekly, with rep tracking/streaks), Events (RSVPs, calendar integration), Profile (account + Brother member records + COPPA consent).

Backend is [Supabase](https://supabase.com) (Postgres + Auth + PostgREST + Edge Functions). The repo root holds the Flutter app (`fraternus_mobile_app/`), the Supabase project (`supabase/`), and domain docs (`docs/`).

**The domain/data model is defined in [`docs/app_concept.md`](docs/app_concept.md) — read it before modeling any feature.** Model new features against its literal entities (User, Member, User Member Association, Chapter, etc.), not ad hoc guesses from mockups. Key concepts:

- A **User** is anyone with a login; a **Member** is someone registered with Fraternus (Brother, Captain, or Commander).
- A **User Member Association** links a User to a Member as either `Self` or `Guardian`.
- Brothers under 13 require COPPA-compliant guardian consent before any data is recorded on their behalf (see ADR 0003 for the cascading-delete implementation).
- Timezones are inferred from the member's chapter location.
- Content (Frat Night Templates, Field Guide entries, Events) is seeded directly into the database — there is no admin UI yet.

Read the ADRs in order for architectural history: [001](docs/adrs/001_initial_archectural_decisions.md) (original on-device-only design, largely superseded), [002](docs/adrs/002_supabase_backend_poc.md) (the Supabase architecture the app runs on today), [003](docs/adrs/003_coppa_child_data_deletion.md) (COPPA deletion). [`SUPABASE_MIGRATION_TODO.md`](SUPABASE_MIGRATION_TODO.md) tracks live migration status — check it before assuming a feature's backend is finished.

## Commands

All Flutter commands run from `fraternus_mobile_app/`.

```bash
flutter pub get                                          # install deps
flutter analyze                                           # must be clean before committing
dart format .                                              # format before committing
flutter test                                               # run all tests
flutter test test/shared/widgets/frat_night_reading_markdown_test.dart   # run a single test file
flutter run -d ios --dart-define-from-file=env/local.json      # run on iOS sim
flutter run -d android --dart-define-from-file=env/local.json  # run on Android emulator
flutter devices                                             # list available devices
```

Regenerate `@riverpod` provider code after adding/editing a provider (generated `*.g.dart` files are committed, so a fresh clone doesn't need this to build — but regenerate before committing your own provider changes):

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Local Supabase backend

```bash
supabase start      # from repo root; boots local Postgres/Auth/PostgREST, applies all migrations on first run
supabase db reset    # rebuild schema from scratch after pulling new migration files
```

Copy `fraternus_mobile_app/env/local.example.json` → `env/local.json` and fill in values from `supabase start`/`supabase status` output (`SUPABASE_URL` = API URL; `SUPABASE_ANON_KEY` = the `sb_publishable_...` **Publishable key**, not the JWT-looking Anon key). `env/local.json` is gitignored.

A fresh local stack only seeds reference data (Chapters, Frat Night Virtues) — no Field Guide weeks, Challenges, or Events. Empty states are expected until you insert rows via Supabase Studio (`http://127.0.0.1:54323`) or `psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres"`. Push notifications (FCM) are not wired up locally — see `SUPABASE_MIGRATION_TODO.md`.

Migration files live in `supabase/migrations/`, timestamp-prefixed and applied in order; Edge Functions live in `supabase/functions/`.

### Widgetbook (design system catalog)

A separate Flutter app at `fraternus_mobile_app/widgetbook/` that path-depends on the main app, kept separate so Widgetbook/`build_runner` never enter the production dependency tree.

```bash
cd fraternus_mobile_app/widgetbook
flutter pub get
flutter pub run build_runner build -d
flutter run -t lib/main.dart -d chrome
```

Use `build_runner watch -d` while actively adding use cases, then hot-reload (`r`) to pick up changes. New `@widgetbook.UseCase`s go in `widgetbook/lib/design_system/...`, mirroring the component's path under `fraternus_mobile_app/lib/design_system/...` — not next to the component itself.

## Architecture

Each feature under `lib/features/{auth,challenge,events,guide,profile,today}/` follows the same shape:

- `models/` — plain Dart data classes
- `data/` — an abstract `XRepository` interface plus a `SupabaseXRepository` implementation (and often an in-memory fake for tests/no-backend use, e.g. `guide_repository.dart`'s in-memory stand-in used by `test/widget_test.dart`)
- `providers/` — `@riverpod` providers (in `x_providers.dart`, generating `x_providers.g.dart`) that wire a repository to the UI
- `presentation/` — `ConsumerWidget` screens, with feature-local widgets under `presentation/widgets/`

**Row Level Security in Postgres is the real authorization boundary, not the Flutter code** — this is why the anon/publishable key is safe to ship in the client. When adding a feature that touches new tables, the RLS policies in the migration are load-bearing, not incidental.

Cross-feature shared code lives in `lib/shared/` (models, repositories/providers used by multiple features — e.g. `chapter_repository.dart`/`chapter_providers.dart` — formatting helpers, widgets). App-wide wiring (Supabase client provider, `go_router` setup, root widget, env config) lives in `lib/app/`. The design system (tokens, buttons, forms, cards, typography, etc.) lives in `lib/design_system/` and is documented/previewed via Widgetbook rather than inline.

Routing uses `go_router` with generated routes (`app/router/app_router.g.dart` from `app/router/app_router.dart`); route path constants are in `app/router/route_paths.dart`.

State/DI is `flutter_riverpod` + `riverpod_annotation` throughout — prefer adding a `@riverpod` function/provider in the relevant feature's `providers/` file over manual `Provider`/`StateNotifier` boilerplate, matching existing patterns (see `guide_providers.dart` for a representative example, including cache-key gotchas like truncating `DateTime` before using it as a family arg).
