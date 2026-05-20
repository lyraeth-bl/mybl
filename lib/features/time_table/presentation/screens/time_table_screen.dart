// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../domain/entities/time_table/time_table.dart';
import '../bloc/time_table_bloc.dart';

class TimeTableScreen extends StatelessWidget {
  const TimeTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TimeTableBloc>(
      create: (context) => di<TimeTableBloc>(),
      child: const _TimeTableView(),
    );
  }
}

class _TimeTableView extends StatefulWidget {
  const _TimeTableView();

  @override
  State<_TimeTableView> createState() => _TimeTableViewState();
}

class _TimeTableViewState extends State<_TimeTableView> {
  static const List<String> _dayValues = [
    _monday,
    _tuesday,
    _wednesday,
    _thursday,
    _friday,
    _saturday,
    _sunday,
  ];
  static const String _monday = 'Senin';
  static const String _tuesday = 'Selasa';
  static const String _wednesday = 'Rabu';
  static const String _thursday = 'Kamis';
  static const String _friday = 'Jumat';
  static const String _saturday = 'Sabtu';
  static const String _sunday = 'Minggu';

  String _selectedDay = _dayValues.first;

  String _studentClass(BuildContext context) {
    return context.read<UserBloc>().state.maybeWhen(
      success: (student) => '${student.kelasSaatIni}${student.noKelasSaatIni}',
      orElse: () => '',
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentClass = _studentClass(context);

      if (studentClass.isNotEmpty) {
        context.read<TimeTableBloc>().add(
          TimeTableEvent.fetchTimeTable(false, studentClass),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: RefreshWrapper(
        onRefresh: () {
          final studentClass = _studentClass(context);
          if (studentClass.isEmpty) return Future<void>.value();

          return blocRefresh<TimeTableBloc, TimeTableEvent, TimeTableState>(
            context: context,
            event: TimeTableEvent.fetchTimeTable(true, studentClass),
            isDone: (state) => state.maybeWhen(
              success: (_) => true,
              failure: (_) => true,
              orElse: () => false,
            ),
          );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const _TimeTableHeader(),
            SliverToBoxAdapter(
              child: _DaySelector(
                dayValues: _dayValues,
                selectedDay: _selectedDay,
                onSelected: (day) => setState(() => _selectedDay = day),
              ),
            ),
            _TimeTableBody(selectedDay: _selectedDay),
          ],
        ),
      ),
    );
  }
}

class _TimeTableHeader extends StatelessWidget {
  const _TimeTableHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SliverAppBar.medium(
      title: Text(
        l10n.timeTable,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: colorScheme.primaryContainer,
      centerTitle: true,
      pinned: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.dayValues,
    required this.selectedDay,
    required this.onSelected,
  });

  final List<String> dayValues;
  final String selectedDay;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: dayValues.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = dayValues[index];

          return ChoiceChip(
            shape: RoundedRectangleBorder(borderRadius: customRadius),
            label: Text(_localizedDay(context, day)),
            selected: day == selectedDay,
            onSelected: (_) => onSelected(day),
          );
        },
      ),
    );
  }

  String _localizedDay(BuildContext context, String day) {
    final l10n = AppLocalizations.of(context)!;

    return switch (day) {
      _TimeTableViewState._monday => l10n.monday,
      _TimeTableViewState._tuesday => l10n.tuesday,
      _TimeTableViewState._wednesday => l10n.wednesday,
      _TimeTableViewState._thursday => l10n.thursday,
      _TimeTableViewState._friday => l10n.friday,
      _TimeTableViewState._saturday => l10n.saturday,
      _TimeTableViewState._sunday => l10n.sunday,
      _ => day,
    };
  }
}

class _TimeTableBody extends StatelessWidget {
  const _TimeTableBody({required this.selectedDay});

  final String selectedDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TimeTableBloc, TimeTableState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => SliverList.list(
            children: const [
              _TimeTableLoadingCard(),
              _TimeTableLoadingCard(),
              _TimeTableLoadingCard(),
            ].makeListAnimate(),
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

            return SliverList.list(
              children: selectedSchedules
                  .map((timeTable) => _TimeTableCard(timeTable: timeTable))
                  .toList()
                  .makeListAnimate(),
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
              _normalizeDay(timeTable.hari) == _normalizeDay(selectedDay),
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

  String _normalizeDay(String value) => value.trim().toLowerCase();
}

class _TimeTableCard extends StatelessWidget {
  const _TimeTableCard({required this.timeTable});

  final TimeTable timeTable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card.filled(
        shape: RoundedRectangleBorder(borderRadius: customRadius),
        color: colorScheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ScheduleTimeBadge(timeTable: timeTable),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeTable.namaMataPelajaran,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeTable.kodeMataPelajaran,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            timeTable.namaGuru,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
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

class _ScheduleTimeBadge extends StatelessWidget {
  const _ScheduleTimeBadge({required this.timeTable});

  final TimeTable timeTable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 86,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: customRadius,
      ),
      child: Column(
        children: [
          Text(
            timeTable.jamMulai,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Divider(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
              height: 1,
            ),
          ),
          Text(
            timeTable.jamSelesai,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child:
          Card.filled(
            margin: EdgeInsets.zero,
            child: const SizedBox(height: 112),
          ).toShimmer(
            context,
            height: 112,
            borderRadius: BorderRadius.circular(12),
          ),
    );
  }
}
