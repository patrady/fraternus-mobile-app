import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/forms/journal_textarea.dart';

@widgetbook.UseCase(name: 'Empty w/ placeholder', type: JournalTextarea)
Widget emptyUseCase(BuildContext context) {
  return const JournalTextarea(placeholder: 'What stood out to you today?');
}

@widgetbook.UseCase(name: 'Filled', type: JournalTextarea)
Widget filledUseCase(BuildContext context) {
  return JournalTextarea(
    controller: TextEditingController(
      text: 'I noticed I was more patient with my brothers today...',
    ),
  );
}

@widgetbook.UseCase(name: 'Custom row count', type: JournalTextarea)
Widget customRowsUseCase(BuildContext context) {
  return const JournalTextarea(placeholder: 'Short answer', rows: 2);
}
