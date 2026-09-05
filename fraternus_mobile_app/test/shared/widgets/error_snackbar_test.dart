import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/shared/widgets/error_snackbar.dart';

void main() {
  Widget wrap(WidgetBuilder builder) =>
      MaterialApp(home: Scaffold(body: Builder(builder: builder)));

  testWidgets('shows the default message when none is given', (tester) async {
    await tester.pumpWidget(
      wrap((context) {
        return ElevatedButton(
          onPressed: () => showErrorSnackBar(context),
          child: const Text('trigger'),
        );
      }),
    );

    await tester.tap(find.text('trigger'));
    await tester.pump();

    expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
  });

  testWidgets('shows a custom message when one is given', (tester) async {
    await tester.pumpWidget(
      wrap((context) {
        return ElevatedButton(
          onPressed: () => showErrorSnackBar(context, 'Could not save changes.'),
          child: const Text('trigger'),
        );
      }),
    );

    await tester.tap(find.text('trigger'));
    await tester.pump();

    expect(find.text('Could not save changes.'), findsOneWidget);
    expect(find.text('Something went wrong. Please try again.'), findsNothing);
  });

  testWidgets('replaces a currently showing snack bar instead of stacking it', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap((context) {
        return Column(
          children: [
            ElevatedButton(
              onPressed: () => showErrorSnackBar(context, 'First failure'),
              child: const Text('first'),
            ),
            ElevatedButton(
              onPressed: () => showErrorSnackBar(context, 'Second failure'),
              child: const Text('second'),
            ),
          ],
        );
      }),
    );

    await tester.tap(find.text('first'));
    await tester.pump();
    await tester.tap(find.text('second'));
    await tester.pump();

    expect(find.text('First failure'), findsNothing);
    expect(find.text('Second failure'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
