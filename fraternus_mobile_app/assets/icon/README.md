# App icon source images

Drop the Fraternus brand icon here before generating launcher icons:

- `icon.png` — full icon, 1024x1024, square. Used for iOS, Android (legacy), web, macOS, Windows.
- `icon_foreground.png` — foreground-only layer (transparent background), 1024x1024, for the Android adaptive icon. The background is filled with `#0B2B25` (forest green) per the `flutter_launcher_icons` config in `pubspec.yaml`.

Once both files are in place, run from `fraternus_mobile_app/`:

```bash
flutter pub get
dart run flutter_launcher_icons
```

This overwrites the existing default Flutter icons under `ios/Runner/Assets.xcassets/AppIcon.appiconset/`, `android/app/src/main/res/mipmap-*`, `web/icons/`, `macos/Runner/Assets.xcassets/AppIcon.appiconset/`, and `windows/runner/resources/app_icon.ico`.
