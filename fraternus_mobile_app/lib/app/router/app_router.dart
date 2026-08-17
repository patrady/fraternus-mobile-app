import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_captain_screen.dart';
import '../../features/auth/presentation/sign_up_guardian_screen.dart';
import '../../features/auth/presentation/sign_up_role_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
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

/// Turns a [Stream] into a [Listenable] so [GoRouter]'s `refreshListenable`
/// re-runs `redirect` on every auth event, without recreating the router
/// (and losing navigation state) the way rebuilding this whole provider on
/// every auth change would. go_router itself doesn't ship this helper as of
/// the version pinned here — this is the standard small wrapper.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

const _authRoutePaths = {
  RoutePaths.signIn,
  RoutePaths.signUp,
  RoutePaths.signUpCaptain,
  RoutePaths.signUpGuardian,
  RoutePaths.forgotPassword,
};

/// The whole app's [GoRouter], as a provider (not a bare top-level
/// constant) so it can depend on [authStateChangesProvider] for the auth
/// gate below.
@riverpod
GoRouter appRouter(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final refreshStream = _GoRouterRefreshStream(authRepository.authStateChanges);
  ref.onDispose(refreshStream.dispose);

  return GoRouter(
    initialLocation: RoutePaths.today,
    refreshListenable: refreshStream,
    redirect: (context, state) {
      final signedIn = authRepository.currentSession != null;
      final onAuthRoute = _authRoutePaths.any((path) => state.matchedLocation.startsWith(path));
      if (!signedIn && !onAuthRoute) return RoutePaths.signIn;
      if (signedIn && onAuthRoute) return RoutePaths.today;
      return null;
    },
    routes: [
      GoRoute(path: RoutePaths.signIn, builder: (context, state) => const SignInScreen()),
      GoRoute(path: RoutePaths.forgotPassword, builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(
        path: RoutePaths.signUp,
        builder: (context, state) => const SignUpRoleScreen(),
        routes: [
          GoRoute(
            path: 'captain',
            builder: (context, state) => const SignUpCaptainScreen(),
          ),
          GoRoute(
            path: 'guardian',
            builder: (context, state) => const SignUpGuardianScreen(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
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
                            builder: (context, state) => EditChildScreen(
                              memberId: state.pathParameters['memberId']!,
                            ),
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
                    builder: (context, state) => EventDetailScreen(
                      eventId: state.pathParameters['eventId']!,
                    ),
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
