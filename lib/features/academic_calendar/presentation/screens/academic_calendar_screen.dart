// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/custom_container.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../domain/entities/academic_calendar_entity.dart';
import '../bloc/academic_calendar_bloc.dart';

class AcademicCalendarScreen extends StatelessWidget {
  const AcademicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AcademicCalendarBloc>(
      create: (context) => di<AcademicCalendarBloc>(),
      child: const _AcademicCalendarView(),
    );
  }
}

class _AcademicCalendarView extends StatefulWidget {
  const _AcademicCalendarView();

  @override
  State<_AcademicCalendarView> createState() => _AcademicCalendarViewState();
}

class _AcademicCalendarViewState extends State<_AcademicCalendarView> {
  late DateTime _focusedMonth;

  List<Widget> get _animatedChildren => [
    _AcademicCalendarNavigationButton(
      focusedMonth: _focusedMonth,
      onPrevious: () => _moveMonth(-1),
      onNext: () => _moveMonth(1),
    ),
    const SizedBox(height: 16),
    _AcademicCalendarContainer(focusedMonth: _focusedMonth),
  ].makeListAnimate();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final unit = _currentStudentUnit(context);
      if (unit == null) {
        context.read<UserBloc>().add(const UserEvent.fetchStudentRequested());
        return;
      }

      _fetchAcademicCalendar(unit: unit);
    });
  }

  String? _currentStudentUnit(BuildContext context) {
    final unit = context.read<UserBloc>().state.maybeWhen(
      success: (student) => student.unit?.trim(),
      orElse: () => null,
    );

    if (unit == null || unit.isEmpty) return null;
    return unit;
  }

  void _fetchAcademicCalendar({
    required String unit,
    bool forceRefresh = false,
  }) {
    context.read<AcademicCalendarBloc>().add(
      AcademicCalendarEvent.fetchAcademicCalendar(
        year: _focusedMonth.year,
        month: _focusedMonth.month,
        unit: unit,
        forceRefresh: forceRefresh,
      ),
    );
  }

  void _moveMonth(int offset) {
    final unit = _currentStudentUnit(context);
    if (unit == null) return;

    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
      );
    });
    _fetchAcademicCalendar(unit: unit);
  }

  Future<void> _refresh() {
    final unit = _currentStudentUnit(context);
    if (unit == null) return Future<void>.value();

    return blocRefresh<
      AcademicCalendarBloc,
      AcademicCalendarEvent,
      AcademicCalendarState
    >(
      context: context,
      event: AcademicCalendarEvent.fetchAcademicCalendar(
        year: _focusedMonth.year,
        month: _focusedMonth.month,
        unit: unit,
        forceRefresh: true,
      ),
      isDone: (state) => state.maybeWhen(
        success: (_, _, _) => true,
        emptyData: () => true,
        failure: (_) => true,
        orElse: () => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (previous, current) {
        final previousUnit = previous.maybeWhen(
          success: (student) => student.unit,
          orElse: () => null,
        );
        final currentUnit = current.maybeWhen(
          success: (student) => student.unit,
          orElse: () => null,
        );

        return previousUnit != currentUnit && currentUnit != null;
      },
      listener: (context, state) {
        final unit = _currentStudentUnit(context);
        if (unit != null) _fetchAcademicCalendar(unit: unit);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        body: RefreshWrapper(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const _AcademicCalendarHeader(),
              SliverToBoxAdapter(child: const SizedBox(height: 24)),
              SliverList.list(children: _animatedChildren),
            ],
          ),
        ),
      ),
    );
  }
}

class _AcademicCalendarHeader extends StatelessWidget {
  const _AcademicCalendarHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SliverAppBar.medium(
      title: Text(
        l10n.academicCalendar,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      centerTitle: true,
      floating: false,
      pinned: true,
    );
  }
}

class _AcademicCalendarNavigationButton extends StatelessWidget {
  const _AcademicCalendarNavigationButton({
    required this.focusedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime focusedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final monthLabel = DateFormat('MMMM yyyy', locale).format(focusedMonth);

    return BlocBuilder<AcademicCalendarBloc, AcademicCalendarState>(
      buildWhen: (previous, current) {
        final previousLoading = previous.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        final currentLoading = current.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        return previousLoading != currentLoading;
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return CustomContainer(
          backgroundColor: colorScheme.surfaceContainerLowest,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  onPressed: isLoading ? null : onPrevious,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: l10n.previousMonth,
                ),
                Flexible(
                  child: Text(
                    monthLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: isLoading ? null : onNext,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: l10n.nextMonth,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AcademicCalendarContainer extends StatelessWidget {
  const _AcademicCalendarContainer({required this.focusedMonth});

  final DateTime focusedMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
        final failure = state.maybeWhen(
          failure: (failure) => failure,
          orElse: () => null,
        );
        final data = state.maybeWhen(
          success: (academicCalendar, _, _) => academicCalendar,
          orElse: () => const <AcademicCalendarEntity>[],
        );

        return RepaintBoundary(
          child: CustomContainer(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerLowest,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _AcademicCalendarContent(
                key: ValueKey((
                  focusedMonth.year,
                  focusedMonth.month,
                  isLoading,
                )),
                focusedMonth: focusedMonth,
                events: data,
                isLoading: isLoading,
                emptyMessage: failure?.localizedMessage(l10n) ?? l10n.noData,
                emptyIcon: failure == null
                    ? Icons.event_busy_outlined
                    : Icons.error_outline,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AcademicCalendarContent extends StatelessWidget {
  const _AcademicCalendarContent({
    super.key,
    required this.focusedMonth,
    required this.events,
    required this.isLoading,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  final DateTime focusedMonth;
  final List<AcademicCalendarEntity> events;
  final bool isLoading;
  final String emptyMessage;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    final eventMap = _buildEventMap(events);

    return Column(
      children: [
        Calendar(focusedDay: focusedMonth, eventMap: eventMap),
        if (!isLoading && events.isEmpty) ...[
          const SizedBox(height: 16),
          _EmptyCalendarMessage(icon: emptyIcon, message: emptyMessage),
        ],
      ],
    );
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

class Calendar extends StatelessWidget {
  const Calendar({super.key, required this.focusedDay, required this.eventMap});

  final DateTime focusedDay;
  final Map<DateTime, List<AcademicCalendarEntity>> eventMap;

  void _showDayDetail(BuildContext context, DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final events = eventMap[key] ?? const <AcademicCalendarEntity>[];

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AcademicCalendarDetailSheet(day: day, events: events),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TableCalendar<AcademicCalendarEntity>(
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
      onDaySelected: (selectedDay, _) => _showDayDetail(context, selectedDay),
      calendarBuilders: CalendarBuilders<AcademicCalendarEntity>(
        defaultBuilder: (context, day, focusedDay) {
          final events = eventMap[DateTime(day.year, day.month, day.day)];
          if (events == null || events.isEmpty) return null;

          return _AcademicCalendarDayCell(day: day);
        },
      ),
    );
  }
}

class _AcademicCalendarDayCell extends StatelessWidget {
  const _AcademicCalendarDayCell({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        shape: BoxShape.circle,
      ),
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

class _EmptyCalendarMessage extends StatelessWidget {
  const _EmptyCalendarMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant, size: 32),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', locale).format(day);
    final hasEvents = events.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: hasEvents ? 0.48 : 0.28,
      minChildSize: 0.24,
      maxChildSize: 0.88,
      expand: false,
      snap: true,
      snapSizes: hasEvents ? const [0.48, 0.88] : const [0.28],
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
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!hasEvents)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              l10n.noData,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ...events.map(
                          (event) => _AcademicCalendarEventCard(event: event),
                        ),
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

class _AcademicCalendarEventCard extends StatelessWidget {
  const _AcademicCalendarEventCard({required this.event});

  final AcademicCalendarEntity event;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Card.filled(
      color: colorScheme.surfaceContainer,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.judul,
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _EventInfoRow(
              icon: Icons.calendar_today_outlined,
              label: l10n.date,
              value: _formatEventRange(event, locale),
            ),
            const SizedBox(height: 8),
            _EventInfoRow(
              icon: Icons.school_outlined,
              label: l10n.unit,
              value: event.unit,
            ),
            if (event.keterangan.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                event.keterangan,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatEventRange(AcademicCalendarEntity event, String locale) {
    final startDate = DateTime.tryParse(event.tanggalMulai);
    final endDate = DateTime.tryParse(event.tanggalSelesai);

    if (startDate == null) return event.tanggalMulai;
    final formatter = DateFormat('d MMM yyyy', locale);
    if (endDate == null || DateUtils.isSameDay(startDate, endDate)) {
      return formatter.format(startDate);
    }

    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }
}

class _EventInfoRow extends StatelessWidget {
  const _EventInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
