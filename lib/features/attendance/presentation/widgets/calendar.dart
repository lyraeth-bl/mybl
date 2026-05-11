// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/attendance_entity/attendance_entity.dart';
import '../../domain/entities/attendance_status/attendance_status.dart';

class Calendar extends StatelessWidget {
  const Calendar({
    super.key,
    required this.focusedDay,
    this.attendanceData = const {},
    this.entityData = const {},
  });

  final DateTime focusedDay;
  final Map<DateTime, AttendanceStatus> attendanceData;
  final Map<DateTime, AttendanceEntity> entityData;

  void _showAttendanceDetail(BuildContext context, DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final entity = entityData[key];
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AttendanceDetailSheet(day: day, entity: entity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TableCalendar(
      focusedDay: focusedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      headerVisible: false,

      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        todayTextStyle: textTheme.bodyLarge!.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
        weekendTextStyle: textTheme.bodyLarge!.copyWith(
          color: colorScheme.error,
        ),
        defaultTextStyle: textTheme.bodyLarge!.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: textTheme.labelLarge!.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
        weekendStyle: textTheme.labelLarge!.copyWith(
          color: colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
      ),

      daysOfWeekHeight: 48,
      startingDayOfWeek: StartingDayOfWeek.monday,
      rowHeight: 60,
      availableGestures: AvailableGestures.none,
      onDaySelected: (selectedDay, _) =>
          _showAttendanceDetail(context, selectedDay),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final status = attendanceData[DateTime(day.year, day.month, day.day)];
          if (status == null) return null;

          return _AttendanceDayCell(day: day, status: status);
        },
      ),
    );
  }
}

class _AttendanceDayCell extends StatelessWidget {
  const _AttendanceDayCell({required this.day, required this.status});

  final DateTime day;
  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (bgColor, textColor) = switch (status) {
      AttendanceStatus.present => (
        Colors.green.withValues(alpha: 0.2),
        Colors.green.shade800,
      ),
      AttendanceStatus.late => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
      ),
      AttendanceStatus.excused => (
        Colors.amber.withValues(alpha: 0.2),
        Colors.amber.shade800,
      ),
      AttendanceStatus.absent => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),
    };

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(
        child: Text(
          '${day.day}',
          style: textTheme.labelSmall!.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AttendanceDetailSheet extends StatelessWidget {
  const _AttendanceDetailSheet({required this.day, this.entity});

  final DateTime day;
  final AttendanceEntity? entity;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final l10n = AppLocalizations.of(context)!;
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', locale).format(day);

    final hasEntity = entity != null;

    return DraggableScrollableSheet(
      initialChildSize: hasEntity ? 0.6 : 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.92,
      expand: false,
      snap: true,
      snapSizes: hasEntity ? [0.6, 0.92] : [0.3],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!hasEntity)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              l10n.noAttendanceDetailData,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        _AttendanceDetailContent(entity: entity!),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AttendanceDetailContent extends StatelessWidget {
  const _AttendanceDetailContent({required this.entity});

  final AttendanceEntity entity;

  String get _statusLabel => switch (entity.status) {
    'Hadir' => 'Hadir',
    'Terlambat' => 'Terlambat',
    'Belum Check-In' => 'Tidak Hadir',
    _ => entity.status,
  };

  (Color, Color, IconData) _statusStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (entity.status) {
      'Hadir' => (
        Colors.green.withValues(alpha: 0.15),
        Colors.green.shade800,
        Icons.check_circle_rounded,
      ),
      'Terlambat' => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
        Icons.watch_later_rounded,
      ),
      'Belum Check-In' => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        Icons.cancel_rounded,
      ),
      _ => (
        Colors.amber.withValues(alpha: 0.15),
        Colors.amber.shade800,
        Icons.info_rounded,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final timeFormat = DateFormat('HH:mm', locale);
    final (bgColor, fgColor, icon) = _statusStyle(context);
    final l10n = AppLocalizations.of(context)!;

    final rows = [
      (
        icon: Icons.school_rounded,
        label: l10n.schoolYear,
        value: entity.tajaran,
      ),
      (
        icon: Icons.layers_rounded,
        label: l10n.semester,
        value: entity.semester,
      ),
      (icon: Icons.location_city_rounded, label: l10n.unit, value: entity.unit),
      (
        icon: Icons.login_rounded,
        label: l10n.checkIn,
        value: entity.jamCheckIn != null
            ? timeFormat.format(entity.jamCheckIn!)
            : '-',
      ),
      (
        icon: Icons.logout_rounded,
        label: l10n.checkOut,
        value: entity.jamCheckOut != null
            ? timeFormat.format(entity.jamCheckOut!)
            : '-',
      ),
      if (entity.alasan != null && entity.alasan!.isNotEmpty)
        (icon: Icons.notes_rounded, label: l10n.reason, value: entity.alasan!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(icon, color: fgColor, size: 28),
              const SizedBox(width: 12),
              Text(
                _statusLabel,
                style: textTheme.titleSmall?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        ...rows.indexed.map(
          (entry) => _DetailRow(
            icon: entry.$2.icon,
            label: entry.$2.label,
            value: entry.$2.value,
            shape: entry.$1.makeVerticalGoogleShape(rows.length - 1),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.shape,
  });

  final IconData icon;
  final String label;
  final String value;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card.filled(
      color: colorScheme.surfaceContainer,
      margin: const EdgeInsets.all(2),
      shape: shape,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
