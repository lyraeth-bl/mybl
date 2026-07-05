// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/utils/subject_icon_resolver.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../domain/entities/time_table/time_table.dart';
import '../bloc/time_table_bloc.dart';

class TimeTableScheduleGroupsSection extends StatelessWidget {
  const TimeTableScheduleGroupsSection({super.key, required this.selectedDay});

  final String selectedDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TimeTableBloc, TimeTableState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: (_) => true,
          orElse: () => false,
        );

        return state.maybeWhen(
          loading: (timeTable) {
            final selectedSchedules = _filterSchedules(timeTable, selectedDay);

            if (selectedSchedules.isEmpty) {
              return SliverPadding(
                padding: const .symmetric(horizontal: 16),
                sliver: SliverList.list(
                  children: const [
                    _TimeTableLoadingCard(),
                    _TimeTableLoadingCard(),
                    _TimeTableLoadingCard(),
                  ],
                ),
              );
            }

            return SliverPadding(
              padding: const .symmetric(horizontal: 16),
              sliver: SliverList.list(
                children: selectedSchedules
                    .map(
                      (timeTable) => _TimeTableCard(
                        timeTable: timeTable,
                        isLoading: isLoading,
                      ),
                    )
                    .toList(),
              ),
            );
          },
          failure: (failure) => AppEmptyStateSliver(
            icon: Icons.error_outline,
            title: l10n.timeTableLoadFailedTitle,
            message: l10n.timeTableLoadFailedSubtitle,
            retryLabel: l10n.tryAgain,
            onRetry: () {
              final studentClass = context.read<UserBloc>().state.maybeWhen(
                success: (student) =>
                    '${student.kelasSaatIni}${student.noKelasSaatIni}',
                orElse: () => '',
              );
              if (studentClass.isEmpty) return;

              context.read<TimeTableBloc>().add(
                .fetchTimeTable(true, studentClass),
              );
            },
          ),
          success: (timeTable) {
            final selectedSchedules = _filterSchedules(timeTable, selectedDay);

            if (selectedSchedules.isEmpty) {
              return AppEmptyStateSliver(
                icon: Icons.event_busy_outlined,
                title: l10n.timeTableNoScheduleTitle,
                message: l10n.timeTableNoScheduleSubtitle,
              );
            }

            return SliverPadding(
              padding: const .symmetric(horizontal: 16),
              sliver: SliverList.list(
                children: selectedSchedules
                    .map((timeTable) => _TimeTableCard(timeTable: timeTable))
                    .toList()
                    .makeListAnimate(),
              ),
            );
          },
          orElse: () => AppEmptyStateSliver(
            icon: Icons.calendar_month_outlined,
            title: l10n.timeTableNoScheduleTitle,
            message: l10n.timeTableNoScheduleSubtitle,
          ),
        );
      },
    );
  }

  List<TimeTable> _filterSchedules(
    List<TimeTable> schedules,
    String selectedDay,
  ) {
    final filtered = schedules
        .where(
          (timeTable) =>
              _normalizeScheduleDay(timeTable.hari) ==
              _normalizeScheduleDay(selectedDay),
        )
        .toList();

    filtered.sort((a, b) {
      final aOrder = int.tryParse(a.jamKe);
      final bOrder = int.tryParse(b.jamKe);

      if (aOrder != null && bOrder != null) return aOrder.compareTo(bOrder);

      return a.jamMulai.compareTo(b.jamMulai);
    });

    return filtered;
  }
}

class _TimeTableCard extends StatelessWidget {
  const _TimeTableCard({required this.timeTable, this.isLoading = false});

  final TimeTable timeTable;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool isOngoing = _isScheduleOngoing(timeTable, DateTime.now());

    return AppContainer(
      margin: const .only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(16),
        side: isOngoing
            ? BorderSide(color: colorScheme.primary)
            : BorderSide.none,
      ),
      borderRadius: null,
      backgroundColor: colorScheme.surface,
      elevation: 0,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            crossAxisAlignment: .center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    if (isOngoing) ...[
                      AppChipContainer(
                        value: l10n.ongoingNow.toUpperCase(),
                        backgroundColor: colorScheme.secondaryContainer,
                        foregroundColor: colorScheme.onSecondaryContainer,
                      ),
                      8.h,
                    ],
                    Text(
                      timeTable.namaMataPelajaran.capitalizeEveryWord,
                      maxLines: 2,
                      overflow: .ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ).toShimmer(
                      context,
                      isLoading: isLoading,
                      width: 160,
                      height: 16,
                      borderRadius: .circular(24),
                    ),
                    8.h,
                    Row(
                      children: [
                        Text(
                          '${timeTable.jamMulai} - ${timeTable.jamSelesai}',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ).toShimmer(
                          context,
                          isLoading: isLoading,
                          width: 120,
                          height: 16,
                          borderRadius: .circular(24),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              16.w,
              AppIconContainer(
                icon: SubjectIconResolver.resolve(timeTable.namaMataPelajaran),
                padding: const .all(8),
                iconSize: 28,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                shape: RoundedRectangleBorder(borderRadius: .circular(8)),
              ).toShimmer(
                context,
                isLoading: isLoading,
                width: 40,
                height: 40,
                borderRadius: .circular(8),
              ),
            ],
          ),
          24.h,
          Divider(color: colorScheme.outlineVariant),
          16.h,
          Row(
            children: <Widget>[
              AppProfilePicture(
                initials: AppProfilePicture.initialFrom(timeTable.namaGuru),
                radius: 20,
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
              16.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeTable.namaGuru.capitalizeEveryWord,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: .bold,
                      ),
                    ).toShimmer(
                      context,
                      isLoading: isLoading,
                      width: 128,
                      height: 16,
                      borderRadius: .circular(24),
                    ),
                  ],
                ),
              ),
              16.w,
              Column(
                crossAxisAlignment: .end,
                children: [
                  Text(
                    l10n.classRoom,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: .bold,
                    ),
                  ),
                  Text(
                    timeTable.kelas,
                    maxLines: 1,
                    overflow: .ellipsis,
                    textAlign: .end,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ).toShimmer(
                    context,
                    isLoading: isLoading,
                    width: 40,
                    height: 16,
                    borderRadius: .circular(24),
                  ),
                ].separatedBy(4.h),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

bool _isScheduleOngoing(TimeTable timeTable, DateTime now) {
  if (_normalizeScheduleDay(timeTable.hari) !=
      _normalizeScheduleDay(_indonesianDayName(now))) {
    return false;
  }

  final start = _timeOfDayFromScheduleTime(timeTable.jamMulai);
  final end = _timeOfDayFromScheduleTime(timeTable.jamSelesai);
  if (start == null || end == null) return false;

  final nowInMinutes = now.hour * Duration.minutesPerHour + now.minute;
  final startInMinutes = start.hour * Duration.minutesPerHour + start.minute;
  final endInMinutes = end.hour * Duration.minutesPerHour + end.minute;

  return nowInMinutes >= startInMinutes && nowInMinutes < endInMinutes;
}

String _normalizeScheduleDay(String value) => value.trim().toLowerCase();

TimeOfDay? _timeOfDayFromScheduleTime(String value) {
  final parts = value.trim().split(':');
  if (parts.length < 2) return null;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);

  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

  return TimeOfDay(hour: hour, minute: minute);
}

String _indonesianDayName(DateTime dateTime) {
  return switch (dateTime.weekday) {
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

class _TimeTableLoadingCard extends StatelessWidget {
  const _TimeTableLoadingCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: const .only(bottom: 8),
      borderRadius: null,
      backgroundColor: colorScheme.surface,
      elevation: 0,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            crossAxisAlignment: .center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    const Text('').toShimmer(context, width: 140, height: 12),
                    const SizedBox(height: 8),
                    const Text('').toShimmer(context, width: 120, height: 16),
                  ],
                ),
              ),
              16.w,
              const Text('').toShimmer(
                context,
                width: 56,
                height: 56,
                borderRadius: .circular(8),
              ),
            ],
          ),
          24.h,
          Divider(color: colorScheme.outlineVariant),
          16.h,
          Row(
            children: [
              const Text('').toShimmer(
                context,
                width: 40,
                height: 40,
                borderRadius: .circular(8),
              ),
              16.w,
              const Expanded(
                child: Text(''),
              ).toShimmer(context, width: 112, height: 12),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('').toShimmer(context, width: 48, height: 10),
                  const Text('').toShimmer(context, width: 48, height: 16),
                ].separatedBy(8.h),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
