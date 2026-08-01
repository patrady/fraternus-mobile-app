import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/buttons/button.dart';
import 'package:fraternus_mobile_app/design_system/tokens/fraternus_colors.dart';
import 'package:fraternus_mobile_app/design_system/tokens/fraternus_typography.dart';
import 'package:fraternus_mobile_app/design_system/layout/screen_shell.dart';

@widgetbook.UseCase(name: 'Light w/ footer', type: ScreenShell)
Widget lightWithFooterUseCase(BuildContext context) {
  return SizedBox(
    height: 600,
    child: ScreenShell(
      footer: Button(label: 'Continue', fullWidth: true, onPressed: () {}),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('Body content scrolls here.', style: FraternusTypography.body()),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Dark', type: ScreenShell)
Widget darkUseCase(BuildContext context) {
  return SizedBox(
    height: 600,
    child: ScreenShell(
      dark: true,
      footer: Button(
        label: 'Skip',
        variant: ButtonVariant.underlined,
        onDark: true,
        onPressed: () {},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('Welcome / splash content.', style: FraternusTypography.body(color: FraternusColors.white)),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'No footer', type: ScreenShell)
Widget noFooterUseCase(BuildContext context) {
  return SizedBox(
    height: 600,
    child: ScreenShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('Body content only, no pinned footer.', style: FraternusTypography.body()),
      ),
    ),
  );
}
