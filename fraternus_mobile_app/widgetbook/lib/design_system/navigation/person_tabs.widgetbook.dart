import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/navigation/person_tabs.dart';

@widgetbook.UseCase(name: 'No status', type: PersonTabs)
Widget noStatusUseCase(BuildContext context) {
  return const PersonTabs(
    people: [PersonTabItem(key: 'you', label: 'You')],
    activeKey: 'you',
    onChanged: _noop,
  );
}

@widgetbook.UseCase(name: 'Done status', type: PersonTabs)
Widget doneUseCase(BuildContext context) {
  return const PersonTabs(
    people: [PersonTabItem(key: 'you', label: 'You', status: PersonTabStatus.done)],
    activeKey: 'you',
    onChanged: _noop,
  );
}

@widgetbook.UseCase(name: 'In-progress status', type: PersonTabs)
Widget inProgressUseCase(BuildContext context) {
  return const PersonTabs(
    people: [PersonTabItem(key: 'jack', label: 'Jack', status: PersonTabStatus.inProgress)],
    activeKey: 'jack',
    onChanged: _noop,
  );
}

@widgetbook.UseCase(name: 'Mixed', type: PersonTabs)
Widget mixedUseCase(BuildContext context) {
  return const PersonTabs(
    people: [
      PersonTabItem(key: 'you', label: 'You', status: PersonTabStatus.done),
      PersonTabItem(key: 'jack', label: 'Jack', status: PersonTabStatus.inProgress),
      PersonTabItem(key: 'thomas', label: 'Thomas'),
    ],
    activeKey: 'you',
    onChanged: _noop,
  );
}

void _noop(String _) {}
