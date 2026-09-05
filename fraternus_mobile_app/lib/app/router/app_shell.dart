import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';
import '../debug_unlock_provider.dart';
import 'route_paths.dart';

const _baseTabs = [
  BottomTabItem(key: 'today', label: 'Today', icon: 'sun'),
  BottomTabItem(key: 'guide', label: 'Guide', icon: 'book-open'),
  BottomTabItem(key: 'challenge', label: 'Challenge', icon: 'mountain'),
  BottomTabItem(key: 'events', label: 'Events', icon: 'calendar-days'),
];

const _baseTabPaths = {
  'today': RoutePaths.today,
  'guide': RoutePaths.guide,
  'challenge': RoutePaths.challenge,
  'events': RoutePaths.events,
};

/// Bridges go_router's [StatefulShellRoute.indexedStack] to the design
/// system's [BottomTabBar] — the single spot every tab-shell screen mounts
/// under, so switching tabs preserves each branch's own navigation stack.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

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
  String _activeKeyFor(
    String location,
    List<BottomTabItem> tabs,
    Map<String, String> tabPaths,
  ) {
    for (final tab in tabs) {
      if (location.startsWith(tabPaths[tab.key]!)) return tab.key;
    }
    // navigationShell.currentIndex indexes the router's own (fixed) branch
    // list, which always includes the debug branch in a debug build
    // regardless of whether the tab bar currently shows it (see
    // app_router.dart) — so this can point past the end of `tabs` right
    // after the unlock gesture hides it. Falling back to the first tab
    // rather than indexing out of bounds.
    return navigationShell.currentIndex < tabs.length
        ? tabs[navigationShell.currentIndex].key
        : tabs.first.key;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debugUnlocked = kDebugMode && ref.watch(debugMenuUnlockedProvider);
    final tabs = [
      ..._baseTabs,
      if (debugUnlocked)
        const BottomTabItem(
          key: 'debug',
          label: 'Debug',
          icon: 'sliders-horizontal',
        ),
    ];
    final tabPaths = {
      ..._baseTabPaths,
      if (debugUnlocked) 'debug': RoutePaths.debug,
    };

    final router = GoRouter.of(context);
    return Column(
      children: [
        Expanded(child: navigationShell),
        ListenableBuilder(
          listenable: router.routerDelegate,
          builder: (context, _) {
            return BottomTabBar(
              tabs: tabs,
              activeKey: _activeKeyFor(
                router.state.matchedLocation,
                tabs,
                tabPaths,
              ),
              onChanged: (key) {
                final index = tabs.indexWhere((tab) => tab.key == key);
                // A task row can push a route (e.g. RoutePaths.challenge) from
                // within another branch's own navigator without switching the
                // active branch, leaving that branch's stack with extra pages
                // on top. Forcing initialLocation whenever the tapped tab is
                // already the active one resets it back to that branch's own
                // root, same as tapping the current tab does in most apps.
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
