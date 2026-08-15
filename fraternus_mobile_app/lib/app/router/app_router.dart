import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/challenge/presentation/challenge_screen.dart';
import '../../features/challenge/presentation/past_challenges_screen.dart';
import '../../features/events/presentation/event_detail_screen.dart';
import '../../features/events/presentation/events_screen.dart';
import '../../features/guide/presentation/guide_screen.dart';
import '../../features/guide/presentation/temperament_detail_screen.dart';
import '../../features/guide/presentation/temperament_quiz_screen.dart';
import '../../features/guide/presentation/virtue_detail_screen.dart';
import '../../features/profile/presentation/add_child_screen.dart';
import '../../features/profile/presentation/edit_child_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/my_kids_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/reminders_screen.dart';
import '../../features/today/presentation/today_screen.dart';
import 'app_shell.dart';
import 'route_paths.dart';

part 'app_router.g.dart';

/// The whole app's [GoRouter], as a provider (not a bare top-level
/// constant) so a future auth gate can add `ref.watch(authStateProvider)` +
/// `redirect:` + `refreshListenable` here without restructuring anything
/// below — the [StatefulShellRoute] doesn't need to move or nest.
@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: RoutePaths.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.today,
                builder: (context, state) => const TodayScreen(),
                routes: [
                  GoRoute(
                    path: RoutePaths.profileSegment,
                    builder: (context, state) => const ProfileScreen(),
                    routes: [
                      GoRoute(
                        path: RoutePaths.editSegment,
                        builder: (context, state) => const EditProfileScreen(),
                      ),
                      GoRoute(
                        path: RoutePaths.kidsSegment,
                        builder: (context, state) => const MyKidsScreen(),
                        routes: [
                          GoRoute(
                            path: RoutePaths.addSegment,
                            builder: (context, state) => const AddChildScreen(),
                          ),
                          GoRoute(
                            path: ':memberId',
                            builder: (context, state) =>
                                EditChildScreen(memberId: state.pathParameters['memberId']!),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: RoutePaths.remindersSegment,
                        builder: (context, state) => const RemindersScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.guide,
                builder: (context, state) => const GuideScreen(),
                routes: [
                  GoRoute(
                    path: RoutePaths.virtueSegment,
                    builder: (context, state) => const VirtueDetailScreen(),
                    routes: [
                      GoRoute(
                        path: '${RoutePaths.temperamentSegment}/:key',
                        builder: (context, state) =>
                            TemperamentDetailScreen(temperamentKey: state.pathParameters['key']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: '${RoutePaths.temperamentQuizSegment}/:personKey',
                    builder: (context, state) =>
                        TemperamentQuizScreen(personKey: state.pathParameters['personKey']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.challenge,
                builder: (context, state) => const ChallengeScreen(),
                routes: [
                  GoRoute(
                    path: RoutePaths.pastSegment,
                    builder: (context, state) => const PastChallengesScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.events,
                builder: (context, state) => const EventsScreen(),
                routes: [
                  GoRoute(
                    path: ':eventId',
                    builder: (context, state) =>
                        EventDetailScreen(eventId: state.pathParameters['eventId']!),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
