// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/presentation/bloc/daily_attendance_bloc/daily_attendance_bloc.dart';
import '../../../attendance/presentation/bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';
import '../../../attendance/presentation/widgets/attendance_qr_bottom_sheet.dart';
import '../../../notifications/domain/entities/app_notification/app_notification.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../time_table/presentation/bloc/time_table_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../widgets/dashboard_profile_section.dart';
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
          create: (context) => di<MonthlyAttendanceBloc>(),
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

      context.read<UserBloc>().add(const UserEvent.fetchStudentRequested());
      context.read<DailyAttendanceBloc>().add(
        const DailyAttendanceEvent.dailyAttendanceRequested(),
      );
      context.read<MonthlyAttendanceBloc>().add(
        MonthlyAttendanceEvent.monthChangeRequested(
          month: now.month,
          year: now.year,
        ),
      );
      context.read<NotificationBloc>().add(
        const NotificationEvent.fetchNotificationsRequested(),
      );

      final studentClass = _studentClass();
      if (studentClass.isNotEmpty) {
        context.read<TimeTableBloc>().add(
          TimeTableEvent.fetchTimeTable(false, studentClass),
        );
      }
    });
  }

  Future<void> _refresh() async {
    final now = DateTime.now();
    final studentClass = _studentClass();

    blocRefresh<UserBloc, UserEvent, UserState>(
      context: context,
      event: const UserEvent.fetchStudentRequested(true),
      isDone: (state) => state.maybeWhen(
        success: (_) => true,
        failure: (_) => true,
        orElse: () => false,
      ),
    );

    blocRefresh<
      DailyAttendanceBloc,
      DailyAttendanceEvent,
      DailyAttendanceState
    >(
      context: context,
      event: const DailyAttendanceEvent.dailyAttendanceRequested(
        forceRefresh: true,
      ),
      isDone: (state) => state.maybeWhen(
        success: (_) => true,
        emptyAttendance: () => true,
        failure: (_) => true,
        orElse: () => false,
      ),
    );

    blocRefresh<
      MonthlyAttendanceBloc,
      MonthlyAttendanceEvent,
      MonthlyAttendanceState
    >(
      context: context,
      event: MonthlyAttendanceEvent.monthChangeRequested(
        month: now.month,
        year: now.year,
        forceRefresh: true,
      ),
      isDone: (state) => state.maybeWhen(
        success: (_, _, _, _, _, _) => true,
        failure: (_) => true,
        orElse: () => false,
      ),
    );

    blocRefresh<NotificationBloc, NotificationEvent, NotificationState>(
      context: context,
      event: const NotificationEvent.fetchNotificationsRequested(),
      isDone: (state) => state.maybeWhen(
        success: (_) => true,
        failure: (_) => true,
        orElse: () => false,
      ),
    );

    if (studentClass.isEmpty) return Future<void>.value();

    if (studentClass.isNotEmpty) {
      blocRefresh<TimeTableBloc, TimeTableEvent, TimeTableState>(
        context: context,
        event: TimeTableEvent.fetchTimeTable(true, studentClass),
        isDone: (state) => state.maybeWhen(
          success: (_) => true,
          failure: (_) => true,
          orElse: () => false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: const _DashboardAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAttendanceQrSheet(context),
        tooltip: AppLocalizations.of(context)!.attendanceQrCode,
        child: const Icon(Icons.qr_code_2),
      ),
      body: _DashboardBody(onRefresh: () async => _refresh()),
    );
  }
}

class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardAppBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.primaryContainer,
      surfaceTintColor: colorScheme.primaryContainer,
      toolbarHeight: 72,
      title: Text(
        "MyBL",
        style: const TextStyle(fontWeight: .bold, letterSpacing: 2),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () async {
            await context.push(RouteNames.notification);
            if (!context.mounted) return;

            context.read<NotificationBloc>().add(
              const NotificationEvent.fetchNotificationsRequested(),
            );
          },
          icon: BlocSelector<NotificationBloc, NotificationState, int>(
            selector: _unreadNotificationCount,
            builder: (context, unreadCount) {
              return Badge.count(
                count: unreadCount,
                isLabelVisible: unreadCount > 0,
                maxCount: 99,
                child: const Icon(Icons.notifications_on_outlined),
              );
            },
          ),
        ),
      ],
      actionsPadding: EdgeInsets.only(right: 16),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: .antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: RefreshWrapper(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const DashboardProfileSection(),
            const DashboardTodayAttendanceSection(),
            const DashboardTimeTableSection(),
          ],
        ),
      ),
    );
  }
}
