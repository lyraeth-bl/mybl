// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/presentation/bloc/daily_attendance_bloc/daily_attendance_bloc.dart';
import '../../../attendance/presentation/bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';
import '../../../notifications/domain/entities/app_notification/app_notification.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../time_table/presentation/bloc/time_table_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../widgets/dashboard_profile_section.dart';
import '../widgets/dashboard_quick_menu_section.dart';
import '../widgets/dashboard_time_table_section.dart';
import '../widgets/dashboard_today_attendance_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DailyAttendanceBloc>(
          create: (context) => di<DailyAttendanceBloc>(),
        ),
        BlocProvider<MonthlyAttendanceBloc>(
          create: (context) => di<MonthlyAttendanceBloc>(param1: false),
        ),
        BlocProvider<TimeTableBloc>(create: (context) => di<TimeTableBloc>()),
        BlocProvider<NotificationBloc>(
          create: (context) => di<NotificationBloc>(),
        ),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  String _studentClass() {
    return context.read<UserBloc>().state.maybeWhen(
      success: (student) => '${student.kelasSaatIni}${student.noKelasSaatIni}',
      orElse: () => '',
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();

      context.read<UserBloc>().add(const .fetchStudentRequested());
      context.read<DailyAttendanceBloc>().add(
        const .dailyAttendanceRequested(),
      );
      context.read<MonthlyAttendanceBloc>().add(
        .monthChangeRequested(month: now.month, year: now.year),
      );
      context.read<NotificationBloc>().add(
        const .fetchNotificationsRequested(),
      );

      final studentClass = _studentClass();
      if (studentClass.isNotEmpty) {
        context.read<TimeTableBloc>().add(.fetchTimeTable(false, studentClass));
      }
    });
  }

  Future<void> _refresh() async {
    final now = DateTime.now();
    final studentClass = _studentClass();
    final refreshes = <Future<void>>[
      blocRefresh<UserBloc, UserEvent, UserState>(
        context: context,
        event: const .fetchStudentRequested(true),
        isDone: (state) => state.maybeWhen(
          success: (_) => true,
          failure: (_) => true,
          orElse: () => false,
        ),
      ),
      blocRefresh<
        DailyAttendanceBloc,
        DailyAttendanceEvent,
        DailyAttendanceState
      >(
        context: context,
        event: const .dailyAttendanceRequested(forceRefresh: true),
        isDone: (state) => state.maybeWhen(
          success: (_) => true,
          emptyAttendance: () => true,
          failure: (_) => true,
          orElse: () => false,
        ),
      ),
      blocRefresh<
        MonthlyAttendanceBloc,
        MonthlyAttendanceEvent,
        MonthlyAttendanceState
      >(
        context: context,
        event: .monthChangeRequested(
          month: now.month,
          year: now.year,
          forceRefresh: true,
        ),
        isDone: (state) => state.maybeWhen(
          success: (_, _, _, _, _, _) => true,
          failure: (_) => true,
          orElse: () => false,
        ),
      ),
      blocRefresh<NotificationBloc, NotificationEvent, NotificationState>(
        context: context,
        event: const .fetchNotificationsRequested(),
        isDone: (state) => state.maybeWhen(
          success: (_) => true,
          failure: (_) => true,
          orElse: () => false,
        ),
      ),
    ];

    if (studentClass.isNotEmpty) {
      refreshes.add(
        blocRefresh<TimeTableBloc, TimeTableEvent, TimeTableState>(
          context: context,
          event: .fetchTimeTable(true, studentClass),
          isDone: (state) => state.maybeWhen(
            success: (_) => true,
            failure: (_) => true,
            orElse: () => false,
          ),
        ),
      );
    }

    await Future.wait(refreshes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      appBar: const _DashboardAppBar(),
      body: _DashboardBody(onRefresh: _refresh),
    );
  }
}

@immutable
class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(
      toolbarHeight: 72,
      title: const Text('MyBL'),
      notificationCount: context.select<NotificationBloc, int>(
        (bloc) => _unreadNotificationCount(bloc.state),
      ),
      notificationTooltip: l10n.notifications,
      onNotificationTap: () async {
        await context.push(RouteNames.notification);
        if (!context.mounted) return;

        context.read<NotificationBloc>().add(
          const .fetchNotificationsRequested(),
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(72);
}

int _unreadNotificationCount(NotificationState state) {
  final notifications = state.maybeWhen(
    loading: (notifications) => notifications,
    success: (notifications) => notifications,
    orElse: () => const <AppNotification>[],
  );

  return notifications.where((notification) => !_isRead(notification)).length;
}

bool _isRead(AppNotification notification) {
  return notification.isRead.toLowerCase() == 'true' ||
      notification.isRead == '1' ||
      notification.isReadAt != null;
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const DashboardProfileSection(),
          const DashboardQuickMenuSection(),
          const DashboardTodayAttendanceSection(),
          const DashboardTimeTableSection(),
          SliverToBoxAdapter(child: 48.h),
        ],
      ),
    );
  }
}
