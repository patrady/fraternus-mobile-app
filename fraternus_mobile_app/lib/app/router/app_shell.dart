import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';

/// Bridges go_router's [StatefulShellRoute.indexedStack] to the design
/// system's [BottomTabBar] — the single spot every tab-shell screen mounts
/// under, so switching tabs preserves each branch's own navigation stack.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    BottomTabItem(key: 'today', label: 'Today', icon: 'sun'),
    BottomTabItem(key: 'guide', label: 'Guide', icon: 'book-open'),
    BottomTabItem(key: 'challenge', label: 'Challenge', icon: 'mountain'),
    BottomTabItem(key: 'events', label: 'Events', icon: 'calendar-days'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: navigationShell),
        BottomTabBar(
          tabs: _tabs,
          activeKey: _tabs[navigationShell.currentIndex].key,
          onChanged: (key) {
            final index = _tabs.indexWhere((tab) => tab.key == key);
            // A task row can push a route (e.g. RoutePaths.challenge) from
            // within another branch's own navigator without switching the
            // active branch, leaving that branch's stack with extra pages
            // on top. Forcing initialLocation whenever the tapped tab is
            // already the active one resets it back to that branch's own
            // root, same as tapping the current tab does in most apps.
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
          },
        ),
      ],
    );
  }
}
