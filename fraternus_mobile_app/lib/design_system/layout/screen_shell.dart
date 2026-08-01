import 'package:flutter/widgets.dart';

import '../tokens/fraternus_colors.dart';

/// Per-screen layout wrapper — full-height column with a top safe-area
/// inset, a scrollable body, and an optional pinned footer (for the
/// primary/secondary button stack). Ports components-source.jsx
/// `ScreenShell`.
class ScreenShell extends StatelessWidget {
  const ScreenShell({super.key, required this.child, this.dark = false, this.footer});

  static const _safeTop = 56.0;

  final Widget child;
  final bool dark;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final background = dark ? FraternusColors.surfaceDark : FraternusColors.surfaceCardDim;
    return ColoredBox(
      color: background,
      child: Padding(
        padding: const EdgeInsets.only(top: _safeTop),
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: child)),
            if (footer != null)
              ColoredBox(
                color: dark ? const Color(0x00000000) : background,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                  child: footer,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
