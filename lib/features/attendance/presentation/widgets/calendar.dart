import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/entities/attendance_status/attendance_status.dart';

class Calendar extends StatelessWidget {
  const Calendar({
    super.key,
    required this.focusedDay,

    this.attendanceData = const {},
  });

  final DateTime focusedDay;
  final Map<DateTime, AttendanceStatus> attendanceData;

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
