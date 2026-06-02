import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
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
          loading: () => SliverMainAxisGroup(
            slivers: const [
              _TimeTableLoadingGroup(),
              _TimeTableLoadingGroup(),
              _TimeTableLoadingGroup(),
            ],
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

            final groupedSchedules = _groupSchedulesByTime(selectedSchedules);

            return SliverMainAxisGroup(
              slivers: groupedSchedules
                  .map(
                    (group) => AppSliverGroup(
                      title: group.timeLabel,
                      headerHeight: 44,
                      headerPadding: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        12,
                        16,
                        4,
                      ),
                      titleStyle: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      sliver: SliverList.list(
                        children: group.schedules
                            .asMap()
                            .entries
                            .map(
                              (entry) => _TimeTableCard(
                                timeTable: entry.value,
                                shape: _scheduleCardShape(
                                  entry.key,
                                  group.schedules.length - 1,
                                ),
                              ),
                            )
                            .toList()
                            .makeListAnimate(),
                      ),
                    ),
                  )
                  .toList(),
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

  List<({String timeLabel, List<TimeTable> schedules})> _groupSchedulesByTime(
    List<TimeTable> schedules,
  ) {
    final grouped = <String, List<TimeTable>>{};

    for (final schedule in schedules) {
      final timeLabel = '${schedule.jamMulai} - ${schedule.jamSelesai}';
      grouped.putIfAbsent(timeLabel, () => <TimeTable>[]).add(schedule);
    }

    return grouped.entries
        .map((entry) => (timeLabel: entry.key, schedules: entry.value))
        .toList();
  }

  ShapeBorder _scheduleCardShape(int index, int lastIndex) {
    if (lastIndex == 0) {
      return RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
    }

    return index.makeVerticalGoogleShape(lastIndex);
  }
}

class _TimeTableCard extends StatelessWidget {
  const _TimeTableCard({required this.timeTable, required this.shape});

  final TimeTable timeTable;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: shape,
      borderRadius: null,
      backgroundColor: colorScheme.surface,
      elevation: 0,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colorScheme.surfaceContainerHighest,
          offset: const Offset(5, 5),
        ),
      ],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  timeTable.namaMataPelajaran,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 96),
                child: Text(
                  timeTable.kodeMataPelajaran,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
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
              const SizedBox(width: 12),
              Icon(
                Icons.meeting_room_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                timeTable.kelas,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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
  const _TimeTableLoadingCard({required this.shape});

  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: shape,
      borderRadius: null,
      backgroundColor: colorScheme.surfaceContainerLowest,
      elevation: 0,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colorScheme.surfaceContainerHighest,
          offset: const Offset(5, 5),
        ),
      ],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('').toShimmer(context, width: 140, height: 14),
              const Spacer(),
              const Text('').toShimmer(context, width: 56, height: 12),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('').toShimmer(
                context,
                width: 18,
                height: 18,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(width: 8),
              const Text('').toShimmer(context, width: 112, height: 12),
              const Spacer(),
              const Text('').toShimmer(
                context,
                width: 18,
                height: 18,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(width: 6),
              const Text('').toShimmer(context, width: 36, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeTableLoadingGroup extends StatelessWidget {
  const _TimeTableLoadingGroup();

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 8),
            child: const Text('').toShimmer(context, width: 96, height: 12),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _TimeTableLoadingCard(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
