import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';

/// Root widget. `MaterialApp.router` is used only for its app-level
/// plumbing (Navigator/Localizations/MediaQuery/Directionality) — every
/// screen composes directly from the raw-widget design system (see
/// `ScreenShell`), not `Scaffold`/`AppBar`.
///
/// The `builder` wraps every route in a borderless [Material] ancestor.
/// Without one, `Text` has no `Material` anywhere above it in the tree
/// (the design system is deliberately built on `package:flutter/widgets.dart`,
/// never `Scaffold`), which renders every line of text with a spurious
/// underline on this Flutter version — confirmed by isolating it down to a
/// bare `MaterialApp -> Text` repro with no design-system code involved.
class FraternusApp extends ConsumerWidget {
  const FraternusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Fraternus',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) => Material(type: MaterialType.transparency, child: child),
    );
  }
}
