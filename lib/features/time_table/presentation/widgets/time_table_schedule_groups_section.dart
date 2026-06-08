// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/utils/subject_icon_resolver.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../l10n/app_localizations.dart';
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
        return state.maybeWhen(
          loading: () => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.list(
              children: const [
                _TimeTableLoadingCard(),
                _TimeTableLoadingCard(),
                _TimeTableLoadingCard(),
              ],
            ),
          ),
          failure: (failure) => SliverFillRemaining(
            hasScrollBody: false,
            child: _TimeTableEmptyView(
              icon: Icons.error_outline,
              message: failure.localizedMessage(l10n),
            ),
          ),
          success: (timeTable) {
            final selectedSchedules = _filterSchedules(timeTable, selectedDay);

            if (selectedSchedules.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: _TimeTableEmptyView(
                  icon: Icons.event_busy_outlined,
                  message: l10n.noData,
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.list(
                children: selectedSchedules
                    .map((timeTable) => _TimeTableCard(timeTable: timeTable))
                    .toList()
                    .makeListAnimate(),
              ),
            );
          },
          orElse: () => SliverFillRemaining(
            hasScrollBody: false,
            child: _TimeTableEmptyView(
              icon: Icons.calendar_month_outlined,
              message: AppLocalizations.of(context)!.noData,
            ),
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
  const _TimeTableCard({required this.timeTable});

  final TimeTable timeTable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isOngoing = _isScheduleOngoing(timeTable, DateTime.now());

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isOngoing
            ? BorderSide(color: colorScheme.primary)
            : BorderSide.none,
      ),
      borderRadius: null,
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isOngoing) ...[
                      AppChipContainer(
                        value: l10n.ongoingNow.toUpperCase(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        backgroundColor: colorScheme.secondaryContainer,
                        foregroundColor: colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      timeTable.namaMataPelajaran,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: .bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${timeTable.jamMulai} - ${timeTable.jamSelesai}',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              AppIconContainer(
                icon: SubjectIconResolver.resolve(timeTable.namaMataPelajaran),
                padding: const EdgeInsets.all(16),
                iconSize: 28,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              AppProfilePicture(
                initials: AppProfilePicture.initialFrom(timeTable.namaGuru),
                radius: 20,
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeTable.namaGuru,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: .bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.classRoom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: .bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeTable.kelas,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: .bold,
                    ),
                  ),
                ],
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

class _TimeTableEmptyView extends StatelessWidget {
  const _TimeTableEmptyView({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeTableLoadingCard extends StatelessWidget {
  const _TimeTableLoadingCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      borderRadius: null,
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('').toShimmer(context, width: 140, height: 16),
                    const SizedBox(height: 8),
                    const Text('').toShimmer(context, width: 104, height: 14),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Text('').toShimmer(
                context,
                width: 56,
                height: 56,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('').toShimmer(
                context,
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(''),
              ).toShimmer(context, width: 112, height: 12),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('').toShimmer(context, width: 48, height: 10),
                  const SizedBox(height: 8),
                  const Text('').toShimmer(context, width: 44, height: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
