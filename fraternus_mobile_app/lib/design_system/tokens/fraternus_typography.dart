import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'fraternus_colors.dart';

/// Typography tokens ported from
/// design_handoff_components/tokens/typography.css.
///
/// CSS letter-spacing there is expressed in `em` (relative to font-size);
/// Flutter's [TextStyle.letterSpacing] is absolute logical pixels, so each
/// style below computes `fontSize * trackingEm`.
abstract final class FraternusTypography {
  static const trackingEyebrowEm = 0.1;
  static const trackingButtonEm = 0.03;

  static TextStyle _display({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double letterSpacingEm = 0,
    Color color = FraternusColors.ink,
  }) => GoogleFonts.oswald(
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: fontSize * letterSpacingEm,
    color: color,
  );

  static TextStyle _body({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    FontStyle fontStyle = FontStyle.normal,
    Color color = FraternusColors.ink,
  }) => GoogleFonts.nunitoSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    fontStyle: fontStyle,
    color: color,
  );

  static TextStyle h1({Color color = FraternusColors.ink}) =>
      _display(fontSize: 76, fontWeight: FontWeight.w700, height: 1.02, color: color);

  static TextStyle h2({Color color = FraternusColors.ink}) =>
      _display(fontSize: 34, fontWeight: FontWeight.w700, height: 1.1, color: color);

  static TextStyle h3({Color color = FraternusColors.ink}) =>
      _display(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: color);

  static TextStyle h4({Color color = FraternusColors.ink}) =>
      _display(fontSize: 18, fontWeight: FontWeight.w600, height: 1.25, color: color);

  static TextStyle eyebrow({Color color = FraternusColors.ink}) => _display(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacingEm: trackingEyebrowEm,
    color: color,
  );

  static TextStyle button({double fontSize = 15, Color color = FraternusColors.ink}) =>
      _display(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        height: 1,
        letterSpacingEm: trackingButtonEm,
        color: color,
      );

  static TextStyle bodyLg({Color color = FraternusColors.ink}) =>
      _body(fontSize: 19, fontWeight: FontWeight.w400, height: 1.6, color: color);

  static TextStyle body({Color color = FraternusColors.ink}) =>
      _body(fontSize: 16, fontWeight: FontWeight.w400, height: 1.55, color: color);

  static TextStyle small({Color color = FraternusColors.ink}) =>
      _body(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: color);

  static TextStyle caption({Color color = FraternusColors.ink}) =>
      _body(fontSize: 13, fontWeight: FontWeight.w400, height: 1.4, color: color);
}
