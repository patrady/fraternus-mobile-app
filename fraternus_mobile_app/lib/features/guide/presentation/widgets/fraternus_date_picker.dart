import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/design_system.dart';

/// [showDatePicker] themed to match the app's brand — parchment/forest
/// surfaces, terracotta selection, Oswald headline — instead of the
/// stock Material blue calendar. Everything is set via [DatePickerThemeData]
/// through the picker's own `builder`, so the rest of the app's (non-
/// Material) design system is untouched.
Future<DateTime?> showFraternusDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) =>
        Theme(data: _datePickerTheme(context), child: child!),
  );
}

ThemeData _datePickerTheme(BuildContext context) {
  final base = Theme.of(context);
  final selectedDayColor = WidgetStateProperty.resolveWith<Color?>((states) {
    if (states.contains(WidgetState.selected))
      return FraternusColors.terracotta;
    return null;
  });
  // Applies to BOTH the plain day-of-month text and "today"'s text — today
  // uses a separate `today*` property that must resolve the same way, or a
  // selected-and-today date renders terracotta digits on a terracotta fill
  // (invisible) instead of falling back to this white-when-selected logic.
  final selectedTextColor = WidgetStateProperty.resolveWith<Color?>((states) {
    if (states.contains(WidgetState.selected)) return FraternusColors.white;
    if (states.contains(WidgetState.disabled))
      return FraternusColors.textOnLightMuted;
    return FraternusColors.ink;
  });
  // "Today, not selected" gets terracotta text (matching its border ring)
  // instead of plain ink, so it still reads as "today" once selection
  // moves off it.
  final todayTextColor = WidgetStateProperty.resolveWith<Color?>((states) {
    if (states.contains(WidgetState.selected)) return FraternusColors.white;
    return FraternusColors.terracotta;
  });
  const noOverlay = WidgetStatePropertyAll<Color?>(Colors.transparent);

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.light,
      primary: FraternusColors.terracotta,
      onPrimary: FraternusColors.white,
      surface: FraternusColors.surfaceCardLight,
      onSurface: FraternusColors.ink,
    ),
    textTheme: GoogleFonts.nunitoSansTextTheme(base.textTheme),
    // The brand's own PressableBuilder uses an opacity dim instead of
    // Material ripples/highlights — match that here rather than let the
    // stock Material splash show through on day cells and Cancel/OK.
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: FraternusColors.terracotta,
        textStyle: FraternusTypography.button(fontSize: 14),
        splashFactory: NoSplash.splashFactory,
        overlayColor: Colors.transparent,
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: FraternusColors.surfaceCardLight,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FraternusRadii.lg),
      ),
      headerBackgroundColor: FraternusColors.surfaceDark,
      headerForegroundColor: FraternusColors.white,
      headerHeadlineStyle: FraternusTypography.h3(color: FraternusColors.white),
      headerHelpStyle: FraternusTypography.eyebrow(
        color: FraternusColors.textOnDarkMuted,
      ),
      weekdayStyle: FraternusTypography.small(
        color: FraternusColors.textOnLightMuted,
      ).copyWith(fontWeight: FontWeight.w700),
      dayStyle: FraternusTypography.body(color: FraternusColors.ink),
      dayForegroundColor: selectedTextColor,
      dayBackgroundColor: selectedDayColor,
      dayOverlayColor: noOverlay,
      todayForegroundColor: todayTextColor,
      todayBackgroundColor: selectedDayColor,
      todayBorder: const BorderSide(color: FraternusColors.terracotta),
      yearStyle: FraternusTypography.body(color: FraternusColors.ink),
      yearForegroundColor: selectedTextColor,
      yearBackgroundColor: selectedDayColor,
      yearOverlayColor: noOverlay,
    ),
  );
}
