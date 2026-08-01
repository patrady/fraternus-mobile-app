import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/navigation/bottom_tab_bar.dart';

const _tabs = [
  BottomTabItem(key: 'today', label: 'Today', icon: 'sun'),
  BottomTabItem(key: 'guide', label: 'Guide', icon: 'book-open'),
  BottomTabItem(key: 'challenge', label: 'Challenge', icon: 'mountain'),
  BottomTabItem(key: 'events', label: 'Events', icon: 'calendar-days'),
];

@widgetbook.UseCase(name: 'Default (Today active)', type: BottomTabBar)
Widget defaultUseCase(BuildContext context) {
  return BottomTabBar(tabs: _tabs, activeKey: 'today', onChanged: (_) {});
}
