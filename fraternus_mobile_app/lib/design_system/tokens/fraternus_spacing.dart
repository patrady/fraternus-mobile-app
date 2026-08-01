import 'package:flutter/widgets.dart';

/// Spacing/radius/shadow tokens ported from
/// design_handoff_components/tokens/spacing.css.
abstract final class FraternusSpacing {
  static const space0 = 4.0;
  static const space1 = 8.0;
  static const space2 = 16.0;
  static const space3 = 24.0;
  static const space4 = 32.0;
  static const space5 = 44.0;
  static const space6 = 60.0;
  static const space7 = 90.0;
  static const space8 = 100.0;

  /// Minimum mobile tap target size.
  static const tapTargetMin = 44.0;
}

abstract final class FraternusRadii {
  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 12.0;
  static const pill = 999.0;
}

abstract final class FraternusShadows {
  static const card = [
    BoxShadow(
      color: Color(0x240B2B25), // rgba(11,43,37,0.14)
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];

  static const popover = [
    BoxShadow(
      color: Color(0x470B2B25), // rgba(11,43,37,0.28)
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];
}
