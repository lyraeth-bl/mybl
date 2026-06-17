// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/academic_calendar/presentation/screens/academic_calendar_screen.dart';
import '../../features/academic_result/presentation/screens/academic_result_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/auth/presentation/screens/auth_parent_screen.dart';
import '../../features/auth/presentation/screens/auth_student_screen.dart';
import '../../features/auth/presentation/screens/parent_child_selector_screen.dart';
import '../../features/user/presentation/bloc/parent_bloc/parent_bloc.dart';
import '../../features/welcome/presentation/screens/welcome_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/widgets/main_shell.dart';
import '../../features/discipline/presentation/screens/merit_demerit_screen.dart';
import '../../features/extracurricular/presentation/screens/extracurricular_screen.dart';
import '../../features/guardians_detail/presentation/screens/guardians_detail_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/profile/presentation/screens/profile_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/sessions/presentation/bloc/session_bloc.dart';
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

      final hasSelectedChild = _parentBloc.state.maybeWhen(
        active: (_) => true,
        orElse: () => false,
      );

      final isOnSplashScreen = state.matchedLocation == RouteNames.splash;

      final isOnAuthScreen =
          state.matchedLocation == RouteNames.welcome ||
          state.matchedLocation == RouteNames.authStudent ||
          state.matchedLocation == RouteNames.authParent;

      final isOnParentFlow =
          state.matchedLocation == RouteNames.parentChildSelector ||
          state.matchedLocation == RouteNames.parentDashboard;

      if (isOnSplashScreen) return null;

      if (!isLoggedIn && !isOnAuthScreen) return RouteNames.welcome;

      if (isLoggedIn && isOnAuthScreen) {
        return isParent ? RouteNames.parentChildSelector : RouteNames.dashboard;
      }

      if (isLoggedIn && isParent) {
        if (!hasSelectedChild && !isOnParentFlow) {
          return RouteNames.parentChildSelector;
        }
      }

      return null;
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

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
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
                path: RouteNames.menu,
                builder: (context, state) => const SizedBox.shrink(),
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
