// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:go_router/go_router.dart';

import '../../features/academic_calendar/presentation/screens/academic_calendar_screen.dart';
import '../../features/academic_result/presentation/screens/academic_result_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/auth/presentation/screens/auth_parent_screen.dart';
import '../../features/auth/presentation/screens/auth_student_screen.dart';
import '../../features/auth/presentation/screens/parent_child_selector_screen.dart';
import '../../features/dashboard/presentation/screens/parent_profile_screen.dart';
import '../../features/dashboard/presentation/shell/parent_main_shell.dart';
import '../../features/dashboard/presentation/shell/student_main_shell.dart';
import '../../features/user/presentation/bloc/parent_bloc/parent_bloc.dart';
import '../../features/welcome/presentation/screens/welcome_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/parent_dashboard_screen.dart';
import '../../features/discipline/presentation/screens/merit_demerit_screen.dart';
import '../../features/extracurricular/presentation/screens/extracurricular_screen.dart';
import '../../features/guardians_detail/presentation/screens/guardians_detail_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/profile/presentation/screens/profile_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/sarpras/presentation/screens/sarpras_screen.dart';
import '../../features/sessions/presentation/bloc/session_bloc.dart';
import '../../features/settings/presentation/screens/help_center_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/time_table/presentation/screens/time_table_screen.dart';
import '../enums/user_role.dart';
import 'go_router_refresh_stream.dart';

part 'route_names.dart';

class AppRouter {
  AppRouter(this._sessionBloc, this._parentBloc);

  final SessionBloc _sessionBloc;
  final ParentBloc _parentBloc;

  late final GoRouter goRouter = GoRouter(
    initialLocation: RouteNames.splash,

    refreshListenable: GoRouterRefreshStream.merged([
      _sessionBloc.stream,
      _parentBloc.stream,
    ]),

    redirect: (context, state) {
      final sessionState = _sessionBloc.state;

      final isReady = sessionState.maybeWhen(
        authenticated: (_, _) => true,
        unauthenticated: () => true,
        orElse: () => false,
      );

      if (!isReady) return null;

      final isLoggedIn = sessionState.maybeWhen(
        authenticated: (_, _) => true,
        orElse: () => false,
      );

      final isParent = sessionState.maybeWhen(
        authenticated: (_, role) => role == UserRole.parent,
        orElse: () => false,
      );

      final isOnSplashScreen = state.matchedLocation == RouteNames.splash;

      final isOnAuthScreen =
          state.matchedLocation == RouteNames.welcome ||
          state.matchedLocation == RouteNames.authStudent ||
          state.matchedLocation == RouteNames.authParent;

      final isOnChildSelector =
          state.matchedLocation == RouteNames.parentChildSelector;

      if (isOnSplashScreen) return null;

      // Belum login.
      if (!isLoggedIn) {
        return isOnAuthScreen ? null : RouteNames.welcome;
      }

      // Login sebagai student.
      if (!isParent) {
        final isOnParentOnlyRoute = state.matchedLocation.startsWith(
          '/parent/',
        );
        return (isOnAuthScreen || isOnParentOnlyRoute)
            ? RouteNames.dashboard
            : null;
      }

      // Login sebagai parent — keputusan rute menunggu ParentBloc selesai
      // hidrasi (baca profil + anak + anak terpilih dari storage).
      final parentState = _parentBloc.state;

      final isParentHydrating = parentState.maybeWhen(
        ready: (_, _, _) => false,
        failure: (_) => false,
        orElse: () => true,
      );

      if (isParentHydrating) {
        // Pindahkan dari auth screen ke selector (yang menampilkan loading);
        // selain itu diam di tempat sampai hidrasi selesai.
        return isOnAuthScreen ? RouteNames.parentChildSelector : null;
      }

      final hasSelectedChild = parentState.maybeWhen(
        ready: (_, _, selectedChild) => selectedChild != null,
        orElse: () => false,
      );

      if (hasSelectedChild) {
        // Parent diarahkan ke dashboard parent (placeholder), bukan dashboard
        // student — supaya tidak menembak endpoint student-only.
        final mustLeave =
            isOnAuthScreen ||
            isOnChildSelector ||
            state.matchedLocation == RouteNames.dashboard;
        return mustLeave ? RouteNames.parentDashboard : null;
      }

      // Parent sudah ter-hidrasi tapi belum memilih anak.
      return isOnChildSelector ? null : RouteNames.parentChildSelector;
    },

    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: RouteNames.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),

      GoRoute(
        path: RouteNames.authStudent,
        builder: (context, state) => const AuthStudentScreen(),
      ),

      GoRoute(
        path: RouteNames.authParent,
        builder: (context, state) => const AuthParentScreen(),
      ),

      GoRoute(
        path: RouteNames.parentChildSelector,
        builder: (context, state) => const ParentChildSelectorScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ParentMainShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <GoRoute>[
              GoRoute(
                path: RouteNames.parentDashboard,
                builder: (context, state) => const ParentDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <GoRoute>[
              GoRoute(
                path: RouteNames.parentNotification,
                builder: (context, state) => const NotificationScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <GoRoute>[
              GoRoute(
                path: RouteNames.parentProfile,
                builder: (context, state) => const ParentProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: RouteNames.attendance,
        builder: (context, state) => const AttendanceScreen(),
      ),

      GoRoute(
        path: RouteNames.profileDetail,
        builder: (context, state) => const ProfileDetailScreen(),
      ),

      GoRoute(
        path: RouteNames.timeTable,
        builder: (context, state) => const TimeTableScreen(),
      ),

      GoRoute(
        path: RouteNames.guardianDetails,
        builder: (context, state) => const GuardiansDetailScreen(),
      ),

      GoRoute(
        path: RouteNames.extracurricular,
        builder: (context, state) => const ExtracurricularScreen(),
      ),

      GoRoute(
        path: RouteNames.sarpras,
        builder: (context, state) => const SarprasScreen(),
      ),

      GoRoute(
        path: RouteNames.meritAndDemerit,
        builder: (context, state) => const MeritDemeritScreen(),
      ),

      GoRoute(
        path: RouteNames.academicCalendar,
        builder: (context, state) => const AcademicCalendarScreen(),
      ),

      GoRoute(
        path: RouteNames.academicResult,
        builder: (context, state) => const AcademicResultScreen(),
      ),

      GoRoute(
        path: RouteNames.notification,
        builder: (context, state) => const NotificationScreen(),
      ),

      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: RouteNames.helpCenter,
        builder: (context, state) => const HelpCenterScreen(),
      ),

      GoRoute(
        path: RouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            StudentMainShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <GoRoute>[
              GoRoute(
                path: RouteNames.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: <GoRoute>[
              GoRoute(
                path: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
