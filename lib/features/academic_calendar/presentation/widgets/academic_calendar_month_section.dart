// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_bl/core/internal/src/extensions/extensions.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/academic_calendar_entity.dart';
import '../bloc/academic_calendar_bloc.dart';
import 'academic_calendar_event_card.dart';
import 'academic_calendar_status.dart';

class AcademicCalendarMonthSection extends StatelessWidget {
  const AcademicCalendarMonthSection({
    super.key,
    required this.focusedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime focusedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  String _monthLabel(DateTime month, String locale) =>
      DateFormat('MMMM yyyy', locale).format(month);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();

    return BlocBuilder<AcademicCalendarBloc, AcademicCalendarState>(
      buildWhen: (previous, current) {
        final previousData = previous.maybeWhen(
          success: (academicCalendar, _, _) => academicCalendar,
          orElse: () => const <AcademicCalendarEntity>[],
        );
        final currentData = current.maybeWhen(
          success: (academicCalendar, _, _) => academicCalendar,
          orElse: () => const <AcademicCalendarEntity>[],
        );

        return previousData != currentData ||
            previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        final data = state.maybeWhen(
          success: (academicCalendar, _, _) => academicCalendar,
          orElse: () => const <AcademicCalendarEntity>[],
        );

        return AppSliverGroup(
          title: _monthLabel(focusedMonth, locale),
          headerHeight: 72,
          backgroundColor: colorScheme.surface,
          contentPadding: EdgeInsets.zero,
          titleStyle: textTheme.titleMedium!.copyWith(
            color: colorScheme.onSurface,
          ),
          action: Row(
            mainAxisSize: .min,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isLoading ? 0.4 : 1,
                child: AppChipContainer(
                  onTap: isLoading ? null : onPrevious,
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.chevron_left_rounded),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isLoading ? 0.4 : 1,
                child: AppChipContainer(
                  onTap: isLoading ? null : onNext,
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ].separatedBy(8.w),
          ),
          child: RepaintBoundary(
            child: ColoredBox(
              color: colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    key: ValueKey((
                      focusedMonth.year,
                      focusedMonth.month,
                      isLoading,
                      data.length,
                    )),
                    children: [
                      _AcademicCalendarMonth(
                        focusedMonth: focusedMonth,
                        events: data,
                      ),
                      16.h,
                      const _AcademicCalendarLegends(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AcademicCalendarLegends extends StatelessWidget {
  const _AcademicCalendarLegends();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        alignment: WrapAlignment.spaceEvenly,
        children: [
          for (final status in AcademicCalendarStatus.values)
            _LegendItem(
              dotColor: academicCalendarStatusDotColor(context, status),
              label: academicCalendarStatusLabel(l10n, status),
            ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.dotColor, required this.label});

  final Color dotColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
        ),
        8.w,
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AcademicCalendarMonth extends StatelessWidget {
  const _AcademicCalendarMonth({
    required this.focusedMonth,
    required this.events,
  });

  final DateTime focusedMonth;
  final List<AcademicCalendarEntity> events;

  @override
  Widget build(BuildContext context) {
    final eventMap = _buildEventMap(events);

    return _CalendarTable(focusedDay: focusedMonth, eventMap: eventMap);
  }

  Map<DateTime, List<AcademicCalendarEntity>> _buildEventMap(
    List<AcademicCalendarEntity> events,
  ) {
    final eventMap = <DateTime, List<AcademicCalendarEntity>>{};

    for (final event in events) {
      final startDate = _parseDate(event.tanggalMulai);
      final endDate = _parseDate(event.tanggalSelesai) ?? startDate;
      if (startDate == null) continue;

      final normalizedEndDate = endDate!.isBefore(startDate)
          ? startDate
          : endDate;
      var day = DateTime(startDate.year, startDate.month, startDate.day);
      final lastDay = DateTime(
        normalizedEndDate.year,
        normalizedEndDate.month,
        normalizedEndDate.day,
      );

      while (!day.isAfter(lastDay)) {
        eventMap.update(
          day,
          (value) => [...value, event],
          ifAbsent: () => [event],
        );
        day = day.add(const Duration(days: 1));
      }
    }

    return eventMap;
  }

  DateTime? _parseDate(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;

    return DateTime.tryParse(normalized);
  }
}

class _CalendarTable extends StatelessWidget {
  const _CalendarTable({required this.focusedDay, required this.eventMap});

  final DateTime focusedDay;
  final Map<DateTime, List<AcademicCalendarEntity>> eventMap;

  void _showDayDetail(BuildContext context, DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final events = eventMap[key] ?? const <AcademicCalendarEntity>[];

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      enableDrag: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => _AcademicCalendarDetailSheet(day: day, events: events),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TableCalendar<AcademicCalendarEntity>(
      focusedDay: focusedDay,
      firstDay: .utc(2020, 1, 1),
      lastDay: .utc(2030, 12, 31),
      headerVisible: false,
      calendarStyle: CalendarStyle(
        weekendTextStyle: textTheme.bodyLarge!.copyWith(
          color: colorScheme.tertiary,
        ),
        defaultTextStyle: textTheme.bodyLarge!.copyWith(
          color: colorScheme.onSurface,
        ),
        outsideDaysVisible: false,
      ),
      daysOfWeekHeight: 32,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: textTheme.labelLarge!.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
        weekendStyle: textTheme.labelLarge!.copyWith(
          color: colorScheme.tertiary,
          fontWeight: FontWeight.bold,
        ),
      ),
      startingDayOfWeek: .monday,
      availableGestures: .none,
      onDaySelected: (selectedDay, _) => _showDayDetail(context, selectedDay),
      calendarBuilders: CalendarBuilders<AcademicCalendarEntity>(
        todayBuilder: (context, day, focusedDay) =>
            _AcademicCalendarTodayCell(day: day),
        defaultBuilder: (context, day, focusedDay) {
          final events = eventMap[DateTime(day.year, day.month, day.day)];
          if (events == null || events.isEmpty) return null;

          return _AcademicCalendarDayCell(
            day: day,
            status: academicCalendarStatusFromEvents(events),
          );
        },
      ),
    );
  }
}

class _AcademicCalendarTodayCell extends StatelessWidget {
  const _AcademicCalendarTodayCell({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SizedBox.square(
        dimension: 40,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: .rectangle,
            borderRadius: .circular(8),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: textTheme.labelSmall!.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AcademicCalendarDayCell extends StatelessWidget {
  const _AcademicCalendarDayCell({required this.day, required this.status});

  final DateTime day;
  final AcademicCalendarStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (backgroundColor, foregroundColor) = academicCalendarStatusColors(
      context,
      status,
    );

    return Center(
      child: SizedBox.square(
        dimension: 40,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: .rectangle,
            borderRadius: .circular(8),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: textTheme.labelSmall!.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AcademicCalendarDetailSheet extends StatelessWidget {
  const _AcademicCalendarDetailSheet({required this.day, required this.events});

  final DateTime day;
  final List<AcademicCalendarEntity> events;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', locale).format(day);
    final hasEvents = events.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: hasEvents ? 0.6 : 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.92,
      expand: false,
      snap: true,
      snapSizes: hasEvents ? const [0.6, 0.92] : const [0.3],
      builder: (context, scrollController) {
        return Column(
          children: [
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
                        color: colorScheme.onSurface,
                      ),
                    ),
                    24.h,
                    if (!hasEvents)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: AppNoData(
                            icon: Icons.event_busy_outlined,
                            title: l10n.noData,
                          ),
                        ),
                      )
                    else
                      ...events.map(
                        (event) => AcademicCalendarEventCard(event: event),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
