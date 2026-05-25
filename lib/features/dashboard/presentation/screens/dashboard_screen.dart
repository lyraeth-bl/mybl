// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/constants/constant.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../core/widgets/titled_content_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/domain/entities/attendance_entity/attendance_entity.dart';
import '../../../attendance/domain/entities/attendance_summary/attendance_summary.dart';
import '../../../attendance/presentation/bloc/daily_attendance_bloc/daily_attendance_bloc.dart';
import '../../../attendance/presentation/bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';
import '../../../attendance/presentation/widgets/attendance_qr_bottom_sheet.dart';
import '../../../time_table/domain/entities/time_table/time_table.dart';
import '../../../time_table/presentation/bloc/time_table_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../widgets/dashboard_header.dart';

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
  late final List<Widget> _animatedChildren;

  String _studentClass() {
    return context.read<UserBloc>().state.maybeWhen(
      success: (student) => '${student.kelasSaatIni}${student.noKelasSaatIni}',
      orElse: () => '',
    );
  }

  @override
  void initState() {
    super.initState();

    _animatedChildren = const [
      SizedBox(height: 16),
      _TodayAttendanceSection(),
      SizedBox(height: 16),
      _TodayScheduleSection(),
      SizedBox(height: 16),
      _MonthlyAttendanceSummarySection(),
      SizedBox(height: 16),
      SizedBox(height: 96),
    ].makeListAnimate();

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

    context.read<UserBloc>().add(const UserEvent.fetchStudentRequested(true));
    context.read<DailyAttendanceBloc>().add(
      const DailyAttendanceEvent.dailyAttendanceRequested(true),
    );
    context.read<MonthlyAttendanceBloc>().add(
      MonthlyAttendanceEvent.monthChangeRequested(
        month: now.month,
        year: now.year,
        forceRefresh: true,
      ),
    );
    if (studentClass.isNotEmpty) {
      context.read<TimeTableBloc>().add(
        TimeTableEvent.fetchTimeTable(true, studentClass),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAttendanceQrSheet(context),
        tooltip: AppLocalizations.of(context)!.attendanceQrCode,
        child: const Icon(Icons.qr_code_2),
      ),
      body: Column(
        children: [
          const DashboardHeader(),
          Expanded(
            child: RefreshWrapper(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [SliverList.list(children: _animatedChildren)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TitledContentContainer(
      title: title,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      contentPadding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

class _TodayAttendanceSection extends StatelessWidget {
  const _TodayAttendanceSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _DashboardSection(
      title: l10n.dailyAttendance,
      child: BlocBuilder<DailyAttendanceBloc, DailyAttendanceState>(
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );
          final attendance = state.whenOrNull(
            success: (dailyAttendance) => dailyAttendance,
          );

          return _TodayAttendanceCard(
            attendance: attendance,
            isLoading: isLoading,
          );
        },
      ),
    );
  }
}

class _TodayAttendanceCard extends StatelessWidget {
  const _TodayAttendanceCard({
    required this.attendance,
    required this.isLoading,
  });

  final AttendanceEntity? attendance;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final status = attendance?.status ?? l10n.noAttendanceData;

    return Material(
      color: colorScheme.surface,
      borderRadius: customRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RouteNames.attendance),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? const _DashboardLoadingBlock(height: 104)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: customRadius,
                          ),
                          child: Icon(
                            Icons.fact_check_outlined,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.today,
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                status,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _AttendanceTimeTile(
                            label: l10n.checkIn,
                            value: _formatNullableTime(
                              attendance?.jamCheckIn,
                              locale,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AttendanceTimeTile(
                            label: l10n.checkOut,
                            value: _formatNullableTime(
                              attendance?.jamCheckOut,
                              locale,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _AttendanceTimeTile extends StatelessWidget {
  const _AttendanceTimeTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: customRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayScheduleSection extends StatelessWidget {
  const _TodayScheduleSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _DashboardSection(
      title: l10n.timeTable,
      child: BlocBuilder<TimeTableBloc, TimeTableState>(
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const _DashboardLoadingBlock(height: 132),
            success: (timeTable) {
              final schedules = _todaySchedules(timeTable).take(3).toList();
              if (schedules.isEmpty) {
                return _DashboardEmptyCard(
                  icon: Icons.calendar_view_week_outlined,
                  message: l10n.noData,
                );
              }

              return Column(
                children: [
                  for (final schedule in schedules)
                    _ScheduleTile(schedule: schedule),
                ],
              );
            },
            failure: (failure) => _DashboardEmptyCard(
              icon: Icons.error_outline,
              message: failure.localizedMessage(l10n),
            ),
            orElse: () => _DashboardEmptyCard(
              icon: Icons.calendar_view_week_outlined,
              message: l10n.noData,
            ),
          );
        },
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.schedule});

  final TimeTable schedule;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colorScheme.surface,
        borderRadius: customRadius,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 58,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: customRadius,
                ),
                child: Column(
                  children: [
                    Text(
                      schedule.jamMulai,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      schedule.jamSelesai,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.namaMataPelajaran,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule.namaGuru,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlyAttendanceSummarySection extends StatelessWidget {
  const _MonthlyAttendanceSummarySection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _DashboardSection(
      title: l10n.attendanceSummary,
      child: BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: (_, _) => true,
            orElse: () => false,
          );
          final summary = state.maybeWhen(
            success: (_, _, _, _, _, summary) => summary,
            orElse: () => const AttendanceSummary(),
          );

          return _AttendanceSummaryCard(summary: summary, isLoading: isLoading);
        },
      ),
    );
  }
}

class _AttendanceSummaryCard extends StatelessWidget {
  const _AttendanceSummaryCard({
    required this.summary,
    required this.isLoading,
  });

  final AttendanceSummary summary;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) return const _DashboardLoadingBlock(height: 132);

    return Material(
      color: colorScheme.surface,
      borderRadius: customRadius,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: summary.attendanceRate.clamp(0, 1),
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SummaryStat(
                    label: l10n.present,
                    value: summary.present,
                  ),
                ),
                Expanded(
                  child: _SummaryStat(label: l10n.late, value: summary.late),
                ),
                Expanded(
                  child: _SummaryStat(
                    label: l10n.excused,
                    value: summary.excused,
                  ),
                ),
                Expanded(
                  child: _SummaryStat(
                    label: l10n.absent,
                    value: summary.absent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          '$value',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DashboardEmptyCard extends StatelessWidget {
  const _DashboardEmptyCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: customRadius,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardLoadingBlock extends StatelessWidget {
  const _DashboardLoadingBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: customRadius,
      ),
      alignment: Alignment.center,
      child: const SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}

String _formatNullableTime(DateTime? time, String locale) {
  if (time == null) return '-';
  return DateFormat('HH:mm', locale).format(time);
}

List<TimeTable> _todaySchedules(List<TimeTable> schedules) {
  final today = _indonesianDayName(DateTime.now().weekday);
  final filtered = schedules
      .where((schedule) => schedule.hari.toLowerCase() == today.toLowerCase())
      .toList();

  filtered.sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
  return filtered;
}

String _indonesianDayName(int weekday) {
  return switch (weekday) {
    DateTime.monday => 'Senin',
    DateTime.tuesday => 'Selasa',
    DateTime.wednesday => 'Rabu',
    DateTime.thursday => 'Kamis',
    DateTime.friday => 'Jumat',
    DateTime.saturday => 'Sabtu',
    DateTime.sunday => 'Minggu',
    _ => '',
  };
}
