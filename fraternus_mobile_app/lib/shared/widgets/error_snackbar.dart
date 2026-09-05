import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';

/// Shows a brief error toast for a background write that failed silently
/// otherwise (an optimistic update that got rolled back, a save that never
/// landed) — the single place every such call site reports failure from, so
/// the look stays consistent app-wide. Safe to call from any callback that
/// still has a valid, mounted [context]; callers must check
/// `context.mounted` themselves after an `await` before calling this.
void showErrorSnackBar(
  BuildContext context, [
  String message = 'Something went wrong. Please try again.',
]) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: FraternusColors.error,
        content: Text(
          message,
          style: FraternusTypography.body(color: FraternusColors.white),
        ),
      ),
    );
}
