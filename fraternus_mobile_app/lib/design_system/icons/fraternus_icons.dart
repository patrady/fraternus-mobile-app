import 'package:flutter/widgets.dart';

/// Maps the icon keys used across design_handoff_components/icons.jsx to
/// codepoints in the Lucide icon font, shipped as an asset by the
/// `lucide_icons` pub package.
///
/// These are built directly as `IconData(codepoint, fontFamily: 'Lucide',
/// fontPackage: 'lucide_icons')` rather than importing
/// `package:lucide_icons/lucide_icons.dart` — that package's generated API
/// subclasses `IconData` (`class LucideIconData extends IconData`), which
/// no longer compiles now that Flutter has marked `IconData` `final`
/// (flutter/flutter#181342). Referencing the font asset directly sidesteps
/// the broken Dart wrapper while still using the same bundled glyphs.
abstract final class FraternusIcons {
  static const _fontFamily = 'Lucide';
  static const _fontPackage = 'lucide_icons';

  static const Map<String, IconData> byName = {
    'chevron-left': IconData(0xf1f9, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'chevron-right': IconData(0xf1fb, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'chevron-down': IconData(0xf1f5, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'heart': IconData(0xf354, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'clock': IconData(0xf221, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'x': IconData(0xf59e, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'circle': IconData(0xf20b, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'circle-check': IconData(0xf1f0, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'triangle-alert': IconData(0xf10d, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'calendar': IconData(0xf1d2, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'circle-dashed': IconData(0xf20c, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'circle-exclaim': IconData(0xf10b, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'flame': IconData(0xf2e9, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'book-open': IconData(0xf1b6, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'mountain': IconData(0xf3ef, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'award': IconData(0xf172, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'sparkles': IconData(0xf4e8, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'party-popper': IconData(0xf437, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'map': IconData(0xf3bf, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'tent': IconData(0xf529, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'users': IconData(0xf574, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'bell': IconData(0xf19c, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'plus': IconData(0xf45e, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'compass': IconData(0xf249, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'calendar-days': IconData(0xf1d6, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'circle-user': IconData(0xf568, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'map-pin': IconData(0xf3c0, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'calendar-plus': IconData(0xf1da, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'sun': IconData(0xf50f, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'shield': IconData(0xf4bf, fontFamily: _fontFamily, fontPackage: _fontPackage),
  };

  /// Falls back to `circle-check` for an unknown name, matching the JSX
  /// helper's fallback behavior.
  static IconData resolve(String name) => byName[name] ?? byName['circle-check']!;
}
