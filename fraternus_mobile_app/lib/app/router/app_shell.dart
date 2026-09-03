import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';
import 'route_paths.dart';

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

  static const _tabPaths = {
    'today': RoutePaths.today,
    'guide': RoutePaths.guide,
    'challenge': RoutePaths.challenge,
    'events': RoutePaths.events,
  };

  /// Which tab to highlight, given the currently-showing location — a task
  /// row can `context.push` a route belonging to another branch (e.g.
  /// `RoutePaths.eventDetail`) without ever calling `goBranch`, which leaves
  /// [navigationShell]'s own `currentIndex` pointing at the origin branch
  /// even though the pushed screen is now on screen.
  ///
  /// This can't be solved with the `state.matchedLocation` the shell
  /// route's own `builder` is handed — that's snapshotted from the last
  /// `go`/`goBranch` navigation and never updates for an imperative `push`
  /// (confirmed empirically: same- and cross-branch pushes both leave it
  /// unchanged). `GoRouter.of(context).state`, read fresh on every
  /// `routerDelegate` notification below, does track pushes correctly.
  String _activeKeyFor(String location) {
    for (final tab in _tabs) {
      if (location.startsWith(_tabPaths[tab.key]!)) return tab.key;
    }
    return _tabs[navigationShell.currentIndex].key;
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return Column(
      children: [
        Expanded(child: navigationShell),
        ListenableBuilder(
          listenable: router.routerDelegate,
          builder: (context, _) {
            return BottomTabBar(
              tabs: _tabs,
              activeKey: _activeKeyFor(router.state.matchedLocation),
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
            );
          },
        ),
      ],
    );
  }
}
