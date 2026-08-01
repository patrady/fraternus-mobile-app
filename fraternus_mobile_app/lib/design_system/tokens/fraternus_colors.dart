import 'package:flutter/widgets.dart';

/// Color tokens ported from design_handoff_components/tokens/colors.css.
abstract final class FraternusColors {
  // Base palette
  static const forestGreen = Color(0xFF0B2B25);
  static const forestGreenDeep = Color(0xFF071F1A);
  static const forestGreenMid = Color(0xFF123A32);
  static const terracotta = Color(0xFFC66737);
  static const terracottaDark = Color(0xFFA8542A);
  static const tan = Color(0xFFC9A876);
  static const tanDim = Color(0xFFA68A63);
  static const parchment = Color(0xFFECE3D9);
  static const parchmentDim = Color(0xFFF6F0E6);
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF16231F);
  static const muted = Color(0xFF4A5651);
  static const border = Color(0xFFE2D6C3);
  static const borderOnDark = Color(0x29FFFFFF); // rgba(255,255,255,0.16)

  // Semantic state
  static const success = Color(0xFF4F7A52);
  static const error = Color(0xFFA8402C);
  static const warning = Color(0xFFC9A876);

  // Semantic surfaces
  static const surfaceDark = forestGreen;
  static const surfaceDarkDeep = forestGreenDeep;
  static const surfaceLight = parchment;
  static const surfaceCardLight = white;
  static const surfaceCardDim = parchmentDim;

  // Semantic text
  static const textOnDark = white;
  static const textOnDarkMuted = Color(0xFFCDDAD5);
  static const textOnLight = ink;
  static const textOnLightMuted = muted;

  // Semantic accents
  static const accentPrimary = terracotta;
  static const accentPrimaryHover = terracottaDark;
  static const accentSecondary = tan;
  static const borderSubtle = border;

  static const focusRing = Color(0x59C66737); // rgba(198,103,55,0.35)
}
