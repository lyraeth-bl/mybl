// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../bloc/daily_attendance_bloc/daily_attendance_bloc.dart';
import '../bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';
import '../widgets/attendance_calendar_section.dart';
import '../widgets/attendance_filtered_section.dart';
import '../widgets/attendance_summary_section.dart';
import '../widgets/attendance_today_section.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isParent = context.read<SessionBloc>().state.maybeWhen(
      authenticated: (_, role) => role == UserRole.parent,
      orElse: () => false,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<DailyAttendanceBloc>(
          create: (context) => di<DailyAttendanceBloc>(param1: isParent),
        ),
        BlocProvider<MonthlyAttendanceBloc>(
          create: (context) => di<MonthlyAttendanceBloc>(param1: isParent),
        ),
      ],
      child: const _AttendanceScreenView(),
    );
  }
}

class _AttendanceScreenView extends StatefulWidget {
  const _AttendanceScreenView();

  @override
  State<_AttendanceScreenView> createState() => _AttendanceScreenViewState();
}

class _AttendanceScreenViewState extends State<_AttendanceScreenView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    final now = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DailyAttendanceBloc>().add(
        const DailyAttendanceEvent.dailyAttendanceRequested(),
      );
      context.read<MonthlyAttendanceBloc>().add(
        MonthlyAttendanceEvent.monthChangeRequested(
          month: now.month,
          year: now.year,
        ),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppTopBar(
        toolbarHeight: 72,
        title: Text(l10n.dailyAttendance),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.today),
            Tab(text: l10n.thisMonth),
            Tab(text: l10n.attendanceSummary),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AttendanceTodayTab(),
          _AttendanceCalendarTab(),
          _AttendanceSummaryTab(),
        ],
      ),
    );
  }
}

Future<void> _refreshMonthlyAttendance(BuildContext context) {
  final state = context.read<MonthlyAttendanceBloc>().state;

  final month = state.maybeWhen(
    success: (m, _, _, _, _, _) => m,
    loading: (m, _) => m,
    orElse: () => DateTime.now().month,
  );
  final year = state.maybeWhen(
    success: (_, y, _, _, _, _) => y,
    loading: (_, y) => y,
    orElse: () => DateTime.now().year,
  );

  return blocRefresh<
    MonthlyAttendanceBloc,
    MonthlyAttendanceEvent,
    MonthlyAttendanceState
  >(
    context: context,
    event: MonthlyAttendanceEvent.monthChangeRequested(
      month: month,
      year: year,
      forceRefresh: true,
    ),
    isDone: (state) => state.maybeWhen(
      success: (_, _, _, _, _, _) => true,
      failure: (_) => true,
      orElse: () => false,
    ),
  );
}

class _AttendanceTodayTab extends StatelessWidget {
  const _AttendanceTodayTab();

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () =>
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
          ),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: const [AttendanceTodaySection()],
      ),
    );
  }
}

class _AttendanceCalendarTab extends StatelessWidget {
  const _AttendanceCalendarTab();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: RefreshWrapper(
        onRefresh: () => _refreshMonthlyAttendance(context),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: const [
            AttendanceCalendarSection(),
            SliverToBoxAdapter(child: SizedBox(height: 24)),
            AttendanceFilteredSection(),
            SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _AttendanceSummaryTab extends StatelessWidget {
  const _AttendanceSummaryTab();

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () => _refreshMonthlyAttendance(context),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: const [
          AttendanceSummarySection(),
          SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
