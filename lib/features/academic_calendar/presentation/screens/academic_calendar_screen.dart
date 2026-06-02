// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
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
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        appBar: const _AcademicCalendarAppBar(),
        body: _AcademicCalendarBody(
          focusedMonth: _focusedMonth,
          onPrevious: () => _moveMonth(-1),
          onNext: () => _moveMonth(1),
          onRefresh: _refresh,
        ),
      ),
    );
  }
}

class _AcademicCalendarAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _AcademicCalendarAppBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: colorScheme.primaryContainer,
      surfaceTintColor: colorScheme.primaryContainer,
      toolbarHeight: 72,
      title: Text(
        l10n.academicCalendar,
        style: const TextStyle(fontWeight: .bold, letterSpacing: 2),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class _AcademicCalendarBody extends StatelessWidget {
  const _AcademicCalendarBody({
    required this.focusedMonth,
    required this.onPrevious,
    required this.onNext,
    required this.onRefresh,
  });

  final DateTime focusedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: RefreshWrapper(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _AcademicCalendarSection(
              focusedMonth: focusedMonth,
              onPrevious: onPrevious,
              onNext: onNext,
            ),
            const _AcademicCalendarEventListSection(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _AcademicCalendarSection extends StatelessWidget {
  const _AcademicCalendarSection({
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
    final l10n = AppLocalizations.of(context)!;
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
          title: l10n.academicCalendar,
          titleStyle: textTheme.titleMedium!.copyWith(
            color: colorScheme.onSurface,
            fontWeight: .bold,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: RepaintBoundary(
            child: AppContainer(
              margin: EdgeInsets.zero,
              elevation: 0,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colorScheme.surfaceContainerHighest,
                  offset: const Offset(5, 5),
                ),
              ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton.filledTonal(
                          onPressed: isLoading ? null : onPrevious,
                          icon: const Icon(Icons.chevron_left),
                          tooltip: l10n.previousMonth,
                        ),
                        Flexible(
                          child: Text(
                            _monthLabel(focusedMonth, locale),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 16),
                    _AcademicCalendarContent(
                      focusedMonth: focusedMonth,
                      events: data,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AcademicCalendarEventListSection extends StatelessWidget {
  const _AcademicCalendarEventListSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSliverGroup(
      title: l10n.academicCalendarLog,
      titleStyle: textTheme.titleMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: BlocBuilder<AcademicCalendarBloc, AcademicCalendarState>(
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
          final events = state.maybeWhen(
            success: (academicCalendar, _, _) =>
                _sortedEvents(academicCalendar),
            orElse: () => const <AcademicCalendarEntity>[],
          );

          if (isLoading) {
            return SliverList.list(
              children: const [
                _AcademicCalendarEventLoadingCard(),
                _AcademicCalendarEventLoadingCard(),
                _AcademicCalendarEventLoadingCard(),
              ],
            );
          }

          if (failure != null) {
            return SliverToBoxAdapter(
              child: _EventListMessage(
                icon: Icons.error_outline,
                message: failure.localizedMessage(l10n),
              ),
            );
          }

          if (events.isEmpty) {
            return SliverToBoxAdapter(
              child: _EventListMessage(
                icon: Icons.event_busy_outlined,
                message: l10n.noData,
              ),
            );
          }

          return SliverList.list(
            children: events
                .asMap()
                .entries
                .map(
                  (entry) => _AcademicCalendarEventCard(
                    event: entry.value,
                    shape: _eventCardShape(entry.key, events.length - 1),
                  ),
                )
                .toList()
                .makeListAnimate(),
          );
        },
      ),
    );
  }

  ShapeBorder _eventCardShape(int index, int lastIndex) {
    if (lastIndex == 0) {
      return RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
    }

    return index.makeVerticalGoogleShape(lastIndex);
  }

  static List<AcademicCalendarEntity> _sortedEvents(
    List<AcademicCalendarEntity> events,
  ) {
    final sortedEvents = [...events];

    sortedEvents.sort((a, b) {
      final aDate = DateTime.tryParse(a.tanggalMulai);
      final bDate = DateTime.tryParse(b.tanggalMulai);

      if (aDate != null && bDate != null) return aDate.compareTo(bDate);

      return a.tanggalMulai.compareTo(b.tanggalMulai);
    });

    return sortedEvents;
  }
}

class _AcademicCalendarContent extends StatelessWidget {
  const _AcademicCalendarContent({
    required this.focusedMonth,
    required this.events,
  });

  final DateTime focusedMonth;
  final List<AcademicCalendarEntity> events;

  @override
  Widget build(BuildContext context) {
    final eventMap = _buildEventMap(events);

    return Calendar(focusedDay: focusedMonth, eventMap: eventMap);
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
  const _AcademicCalendarEventCard({required this.event, this.shape});

  final AcademicCalendarEntity event;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: shape,
      borderRadius: shape == null ? BorderRadius.circular(8) : null,
      backgroundColor: colorScheme.surfaceContainerLowest,
      elevation: 0,
      boxShadow: shape == null
          ? null
          : <BoxShadow>[
              BoxShadow(
                color: colorScheme.surfaceContainerHighest,
                offset: const Offset(5, 5),
              ),
            ],
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

class _AcademicCalendarEventLoadingCard extends StatelessWidget {
  const _AcademicCalendarEventLoadingCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: 0,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colorScheme.surfaceContainerHighest,
          offset: const Offset(5, 5),
        ),
      ],
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LoadingBox(width: 180, height: 14),
          SizedBox(height: 12),
          _LoadingBox(width: 140, height: 12),
          SizedBox(height: 10),
          _LoadingBox(width: 96, height: 12),
        ],
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox({this.width, required this.height});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return const SizedBox().toShimmer(
      context,
      width: width ?? double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

class _EventListMessage extends StatelessWidget {
  const _EventListMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
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
    );
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
