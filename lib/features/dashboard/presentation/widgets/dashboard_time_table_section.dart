// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/subject_icon_resolver.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../time_table/domain/entities/time_table/time_table.dart';
import '../../../time_table/presentation/bloc/time_table_bloc.dart';

class DashboardTimeTableSection extends StatelessWidget {
  const DashboardTimeTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: l10n.timeTable,
      titleStyle: textTheme.titleMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      action: TextButton(
        onPressed: () => context.push(RouteNames.timeTable),
        child: Text(l10n.seeAll),
      ),
      sliver: BlocBuilder<TimeTableBloc, TimeTableState>(
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: (_) => true,
            orElse: () => false,
          );

          return state.maybeWhen(
            loading: (_) => SliverList.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                final shape = index.makeVerticalGoogleShape(2);
                final iconColors = _timeTableIconColors(context, index);

                return _TimeTableContainer(
                  subject: '',
                  teacherName: '',
                  timeStart: '',
                  timeEnd: '',
                  durationLabel: null,
                  isLoading: isLoading,
                  shape: shape,
                  iconBackgroundColor: iconColors.backgroundColor,
                  iconForegroundColor: iconColors.foregroundColor,
                );
              },
            ),
            success: (timeTableList) {
              final preview = _todaySchedulePreview(l10n, timeTableList);

              if (preview.message != null) {
                final type = switch (preview.icon) {
                  Icons.weekend_outlined => _MessageType.holiday,
                  Icons.check_circle_outline => _MessageType.success,
                  _ => _MessageType.info,
                };

                final subtitle = switch (type) {
                  _MessageType.holiday => l10n.enjoyYourHolidaySubtitle,
                  _MessageType.success => l10n.todayScheduleFinishedSubtitle,
                  _ => null,
                };

                return SliverToBoxAdapter(
                  child: _TimeTableMessageContainer(
                    icon: preview.icon ?? Icons.calendar_month_outlined,
                    message: preview.message!,
                    subtitle: subtitle,
                    type: type,
                  ),
                );
              }

              final schedules = preview.schedules.take(3).toList();

              if (schedules.isEmpty) {
                return SliverToBoxAdapter(
                  child: _TimeTableMessageContainer(
                    icon: Icons.event_busy_outlined,
                    message: l10n.noData,
                    type: _MessageType.info,
                  ),
                );
              }

              return SliverList.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final timeTable = schedules[index];
                  final shape = index.makeVerticalGoogleShape(
                    schedules.length - 1,
                  );
                  final iconColors = _timeTableIconColors(context, index);

                  return _TimeTableContainer(
                    subject: timeTable.namaMataPelajaran,
                    teacherName: timeTable.namaGuru,
                    timeStart: timeTable.jamMulai,
                    timeEnd: timeTable.jamSelesai,
                    durationLabel: _scheduleDurationLabel(l10n, timeTable),
                    isLoading: isLoading,
                    shape: shape,
                    iconBackgroundColor: iconColors.backgroundColor,
                    iconForegroundColor: iconColors.foregroundColor,
                  );
                },
              );
            },
            failure: (_) => SliverToBoxAdapter(
              child: _TimeTableMessageContainer(
                icon: Icons.error_outline,
                message: l10n.noData,
                type: _MessageType.error,
              ),
            ),
            orElse: () => SliverToBoxAdapter(
              child: _TimeTableMessageContainer(
                icon: Icons.calendar_month_outlined,
                message: l10n.noData,
                type: _MessageType.info,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeTableContainer extends StatelessWidget {
  const _TimeTableContainer({
    this.shape,
    required this.subject,
    required this.teacherName,
    required this.timeStart,
    required this.timeEnd,
    this.durationLabel,
    required this.isLoading,
    required this.iconBackgroundColor,
    required this.iconForegroundColor,
  });

  final ShapeBorder? shape;
  final String subject;
  final String teacherName;
  final String timeStart;
  final String timeEnd;
  final String? durationLabel;
  final bool isLoading;
  final Color iconBackgroundColor;
  final Color iconForegroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppContainer(
      backgroundColor: colorScheme.surfaceContainerLow,
      margin: EdgeInsets.symmetric(vertical: 2),
      shape: shape,
      borderRadius: null,
      elevation: 0,
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          AppIconContainer(
            icon: SubjectIconResolver.resolve(subject),
            backgroundColor: iconBackgroundColor,
            foregroundColor: iconForegroundColor,
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ).toShimmer(
            context,
            isLoading: isLoading,
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(8),
          ),

          const SizedBox(width: 24),

          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  subject,
                  style: textTheme.titleMedium!.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: .bold,
                  ),
                ).toShimmer(
                  context,
                  isLoading: isLoading,
                  width: 80,
                  height: 12,
                ),

                const SizedBox(height: 8),

                Text(
                  teacherName,
                  style: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ).toShimmer(
                  context,
                  isLoading: isLoading,
                  width: 80,
                  height: 12,
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          Column(
            crossAxisAlignment: .end,
            children: [
              Text(
                "$timeStart - $timeEnd",
                style: textTheme.titleMedium!.copyWith(
                  color: colorScheme.primary,
                  fontWeight: .bold,
                ),
              ).toShimmer(context, isLoading: isLoading, width: 80, height: 12),

              const SizedBox(height: 8),

              if (isLoading || durationLabel != null)
                Text(
                  durationLabel ?? '',
                  style: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ).toShimmer(
                  context,
                  isLoading: isLoading,
                  width: 24,
                  height: 12,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

({Color backgroundColor, Color foregroundColor}) _timeTableIconColors(
  BuildContext context,
  int index,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final appColors = AppColors.of(context);

  return switch (index % 3) {
    0 => (
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
    ),
    1 => (
      backgroundColor: appColors.warning.withValues(alpha: 0.6),
      foregroundColor: _foregroundColorFor(context, appColors.warning),
    ),
    _ => (
      backgroundColor: colorScheme.tertiaryContainer,
      foregroundColor: colorScheme.onTertiaryContainer,
    ),
  };
}

Color _foregroundColorFor(BuildContext context, Color backgroundColor) {
  final colorScheme = Theme.of(context).colorScheme;
  final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);

  return brightness == Brightness.dark
      ? colorScheme.onPrimary
      : colorScheme.scrim;
}

({String day, List<TimeTable> schedules, IconData? icon, String? message})
_todaySchedulePreview(AppLocalizations l10n, List<TimeTable> schedules) {
  final today = DateTime.now().weekday;
  final todayName = _indonesianDayName(today);
  final todayLabel = _localizedDayName(l10n, today);

  if (today == DateTime.saturday || today == DateTime.sunday) {
    return (
      day: todayLabel,
      schedules: <TimeTable>[],
      icon: Icons.weekend_outlined,
      message: l10n.enjoyYourHoliday,
    );
  }

  final todaySchedules = _schedulesForDay(schedules, todayName);

  if (todaySchedules.isEmpty) {
    return (
      day: todayLabel,
      schedules: <TimeTable>[],
      icon: null,
      message: null,
    );
  }

  if (_isScheduleDayCompleted(todaySchedules, DateTime.now())) {
    return (
      day: todayLabel,
      schedules: <TimeTable>[],
      icon: Icons.check_circle_outline,
      message: l10n.todayScheduleFinished,
    );
  }

  return (
    day: todayLabel,
    schedules: _currentAndUpcomingSchedules(todaySchedules, DateTime.now()),
    icon: null,
    message: null,
  );
}

String? _scheduleDurationLabel(AppLocalizations l10n, TimeTable schedule) {
  final start = _timeOfDayFromScheduleTime(schedule.jamMulai);
  final end = _timeOfDayFromScheduleTime(schedule.jamSelesai);

  if (start == null || end == null) return null;

  final startInMinutes = start.hour * Duration.minutesPerHour + start.minute;
  final endInMinutes = end.hour * Duration.minutesPerHour + end.minute;
  final duration = endInMinutes - startInMinutes;

  if (duration <= 0) return null;

  return l10n.scheduleDurationMinutes(duration);
}

List<TimeTable> _schedulesForDay(List<TimeTable> schedules, String day) {
  final normalizedDay = _normalizeDay(day);
  final filtered = schedules
      .where((schedule) => _normalizeDay(schedule.hari) == normalizedDay)
      .toList();

  filtered.sort((a, b) {
    final aOrder = int.tryParse(a.jamKe);
    final bOrder = int.tryParse(b.jamKe);

    if (aOrder != null && bOrder != null) return aOrder.compareTo(bOrder);

    return a.jamMulai.compareTo(b.jamMulai);
  });

  return filtered;
}

List<TimeTable> _currentAndUpcomingSchedules(
  List<TimeTable> schedules,
  DateTime now,
) {
  final nowInMinutes = now.hour * Duration.minutesPerHour + now.minute;
  final firstActiveOrUpcomingIndex = schedules.indexWhere((schedule) {
    final end = _timeOfDayFromScheduleTime(schedule.jamSelesai);
    if (end == null) return false;

    final endInMinutes = end.hour * Duration.minutesPerHour + end.minute;

    return nowInMinutes < endInMinutes;
  });

  if (firstActiveOrUpcomingIndex == -1) return schedules;

  return schedules.skip(firstActiveOrUpcomingIndex).toList();
}

String _normalizeDay(String value) => value.trim().toLowerCase();

bool _isScheduleDayCompleted(List<TimeTable> schedules, DateTime now) {
  final endTimes = schedules
      .map((schedule) => _timeOfDayFromScheduleTime(schedule.jamSelesai))
      .nonNulls
      .toList();

  if (endTimes.isEmpty) return false;
  final nowInMinutes = now.hour * Duration.minutesPerHour + now.minute;

  return endTimes.every((endTime) {
    final endInMinutes =
        endTime.hour * Duration.minutesPerHour + endTime.minute;

    return nowInMinutes >= endInMinutes;
  });
}

TimeOfDay? _timeOfDayFromScheduleTime(String value) {
  final parts = value.trim().split(':');
  if (parts.length < 2) return null;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);

  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

  return TimeOfDay(hour: hour, minute: minute);
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

String _localizedDayName(AppLocalizations l10n, int weekday) {
  return switch (weekday) {
    DateTime.monday => l10n.monday,
    DateTime.tuesday => l10n.tuesday,
    DateTime.wednesday => l10n.wednesday,
    DateTime.thursday => l10n.thursday,
    DateTime.friday => l10n.friday,
    DateTime.saturday => l10n.saturday,
    DateTime.sunday => l10n.sunday,
    _ => '',
  };
}

class _TimeTableMessageContainer extends StatelessWidget {
  const _TimeTableMessageContainer({
    required this.icon,
    required this.message,
    this.subtitle,
    this.type = _MessageType.info,
  });

  final IconData icon;
  final String message;
  final String? subtitle;
  final _MessageType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final colors = type.resolveColors(colorScheme, appColors);

    return AppContainer(
      backgroundColor: colors.background,
      margin: EdgeInsets.zero,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          AppIconContainer(
            icon: icon,
            backgroundColor: colors.iconBackground,
            foregroundColor: colors.iconForeground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: textTheme.titleMedium!.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _MessageType { info, success, holiday, error }

extension _MessageTypeX on _MessageType {
  ({Color background, Color iconBackground, Color iconForeground})
  resolveColors(ColorScheme colorScheme, AppColors appColors) {
    return switch (this) {
      _MessageType.success => (
        background: appColors.success.withValues(alpha: 0.08),
        iconBackground: appColors.success.withValues(alpha: 0.2),
        iconForeground: appColors.success,
      ),
      _MessageType.holiday => (
        background: appColors.warning.withValues(alpha: 0.08),
        iconBackground: appColors.warning.withValues(alpha: 0.2),
        iconForeground: appColors.warning,
      ),
      _MessageType.error => (
        background: colorScheme.errorContainer.withValues(alpha: 0.4),
        iconBackground: colorScheme.errorContainer,
        iconForeground: colorScheme.onErrorContainer,
      ),
      _MessageType.info => (
        background: colorScheme.surfaceContainerLow,
        iconBackground: colorScheme.primaryContainer,
        iconForeground: colorScheme.onPrimaryContainer,
      ),
    };
  }
}
