# Fraternus Mobile App

A Flutter application for [Fraternus](https://fraternus.net), a Catholic brotherhood program for young men. Available free on iOS and Android.

## What is this?

The Fraternus app supports two types of users: **Captains** (adult mentors/leaders) and **Guardians** (parents of Brothers). It provides:

- **Field Guide** — Daily devotionals organized by weekly virtue themes, with identity readings, wisdom quotes, a daily challenge (Sword), a reflection (Spade), and a closing prayer. Tracks consecutive-day streaks.
- **Challenges** — Weekly challenges assigned at Frat Night. Captains and Guardians can track reps on behalf of Brothers. Tracks consecutive-week streaks.
- **Events** — Frat Nights, Excursions, Ranch (Summer Camp), HAWC Nights, and other chapter events. Supports RSVPs and calendar integration.
- **Profile** — Account management for Captains and Guardians, including Brother member records and COPPA-compliant consent tracking for members under 13.

Authentication is handled via Auth0 (username/password or passkey).

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- [Dart SDK](https://dart.dev/get-dart) (bundled with Flutter)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development, macOS only)
- [Android Studio](https://developer.android.com/studio) with Android SDK (for Android development)
- An Auth0 tenant configured for this app

Verify your Flutter environment:

```bash
flutter doctor
```

## Installing Dependencies

```bash
flutter pub get
```

## Running the App

**iOS Simulator:**

```bash
flutter run -d ios
```

**Android Emulator:**

```bash
flutter run -d android
```

**List available devices:**

```bash
flutter devices
```

**Run on a specific device:**

```bash
flutter run -d <device-id>
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
