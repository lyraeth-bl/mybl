// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../domain/entities/academic_calendar_entity.dart';
import '../bloc/academic_calendar_bloc.dart';
import 'academic_calendar_event_card.dart';
import 'academic_calendar_status.dart';

class AcademicCalendarEventListSection extends StatefulWidget {
  const AcademicCalendarEventListSection({
    super.key,
    required this.focusedMonth,
  });

  final DateTime focusedMonth;

  @override
  State<AcademicCalendarEventListSection> createState() =>
      _AcademicCalendarEventListSectionState();
}

class _AcademicCalendarEventListSectionState
    extends State<AcademicCalendarEventListSection> {
  AcademicCalendarStatus? _selectedStatus;

  void _retryFetch() {
    final unit = context.read<UserBloc>().state.maybeWhen(
      success: (student) => student.unit?.trim(),
      orElse: () => null,
    );
    if (unit == null || unit.isEmpty) return;

    context.read<AcademicCalendarBloc>().add(
      AcademicCalendarEvent.fetchAcademicCalendar(
        year: widget.focusedMonth.year,
        month: widget.focusedMonth.month,
        unit: unit,
        forceRefresh: true,
      ),
    );
  }

  bool get _isPastMonth {
    final now = DateTime.now();
    final focused = DateTime(
      widget.focusedMonth.year,
      widget.focusedMonth.month,
    );
    final current = DateTime(now.year, now.month);

    return focused.isBefore(current);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSliverGroup(
      title: _isPastMonth
          ? l10n.academicCalendarPastEvents
          : l10n.academicCalendarUpcomingEvents,
      titleStyle: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface),
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
          final filteredEvents = _filteredEvents(events);

          if (isLoading) {
            return SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _AcademicCalendarFilterBar(selectedStatus: null),
                  SizedBox(height: 16),
                  AcademicCalendarEventLoadingCard(),
                  AcademicCalendarEventLoadingCard(),
                  AcademicCalendarEventLoadingCard(),
                ],
              ),
            );
          }

          if (failure != null) {
            return AppEmptyStateSliver(
              icon: Icons.wifi_off_rounded,
              title: l10n.academicCalendarLoadFailedTitle,
              message: failure.localizedMessage(l10n),
              retryLabel: l10n.tryAgain,
              onRetry: _retryFetch,
            );
          }

          if (filteredEvents.isEmpty) {
            return SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AcademicCalendarFilterBar(
                    selectedStatus: _selectedStatus,
                    onChanged: _changeStatus,
                  ),
                  const SizedBox(height: 16),
                  AppContainer(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    backgroundColor: colorScheme.surface,
                    elevation: 0,
                    borderRadius: null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: AppNoData(
                      icon: Icons.event_busy_outlined,
                      title: _isPastMonth
                          ? l10n.academicCalendarPastEventsEmptyTitle
                          : l10n.academicCalendarUpcomingEventsEmptyTitle,
                      message: _isPastMonth
                          ? l10n.academicCalendarPastEventsEmptyMessage
                          : l10n.academicCalendarUpcomingEventsEmptyMessage,
                    ),
                  ),
                ],
              ),
            );
          }

          return SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AcademicCalendarFilterBar(
                  selectedStatus: _selectedStatus,
                  onChanged: _changeStatus,
                ),
                const SizedBox(height: 16),
                ...filteredEvents
                    .map((event) => AcademicCalendarEventCard(event: event))
                    .toList()
                    .makeListAnimate(),
              ],
            ),
          );
        },
      ),
    );
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

  List<AcademicCalendarEntity> _filteredEvents(
    List<AcademicCalendarEntity> events,
  ) {
    final status = _selectedStatus;
    if (status == null) return events;

    return events
        .where(
          (event) => academicCalendarStatusFromTitle(event.judul) == status,
        )
        .toList();
  }

  void _changeStatus(AcademicCalendarStatus? status) {
    setState(() => _selectedStatus = status);
  }
}

class _AcademicCalendarFilterBar extends StatelessWidget {
  const _AcademicCalendarFilterBar({
    required this.selectedStatus,
    this.onChanged,
  });

  final AcademicCalendarStatus? selectedStatus;
  final ValueChanged<AcademicCalendarStatus?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: .horizontal,
      child: Row(
        children: [
          _StatusFilterChip(
            label: l10n.all,
            selected: selectedStatus == null,
            onTap: onChanged == null ? null : () => onChanged!(null),
          ),
          ...AcademicCalendarStatus.values.map(
            (status) => _StatusFilterChip(
              label: academicCalendarStatusLabel(l10n, status),
              selected: selectedStatus == status,
              onTap: onChanged == null ? null : () => onChanged!(status),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppChipContainer(
      value: label,
      onTap: onTap,
      margin: const EdgeInsetsDirectional.only(end: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      backgroundColor: selected
          ? colorScheme.primaryContainer
          : colorScheme.surface,
      foregroundColor: selected
          ? colorScheme.onPrimaryContainer
          : colorScheme.onSurface,
      side: selected
          ? BorderSide.none
          : BorderSide(color: colorScheme.outlineVariant),
    );
  }
}
