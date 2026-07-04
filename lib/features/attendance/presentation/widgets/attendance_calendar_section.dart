import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/attendance_entity/attendance_entity.dart';
import '../../domain/entities/attendance_status/attendance_status.dart';
import '../bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';
import 'attendance_calendar.dart';

class AttendanceCalendarSection extends StatelessWidget {
  const AttendanceCalendarSection({super.key});

  String _monthLabel(int month, int year, String locale) =>
      DateFormat('MMMM yyyy', locale).format(DateTime(year, month));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return AppSliverGroup(
      title: l10n.attendanceCalendar,
      titleStyle: textTheme.titleMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
        buildWhen: (prev, curr) {
          final prevData = (
            month: prev.maybeWhen(
              success: (m, _, _, _, _, _) => m,
              loading: (m, _) => m,
              orElse: () => 0,
            ),
            year: prev.maybeWhen(
              success: (_, y, _, _, _, _) => y,
              loading: (_, y) => y,
              orElse: () => 0,
            ),
            map: prev.maybeWhen(
              success: (_, _, _, am, _, _) => am,
              orElse: () => null,
            ),
            isLoading: prev.maybeWhen(
              loading: (_, _) => true,
              orElse: () => false,
            ),
          );
          final currData = (
            month: curr.maybeWhen(
              success: (m, _, _, _, _, _) => m,
              loading: (m, _) => m,
              orElse: () => 0,
            ),
            year: curr.maybeWhen(
              success: (_, y, _, _, _, _) => y,
              loading: (_, y) => y,
              orElse: () => 0,
            ),
            map: curr.maybeWhen(
              success: (_, _, _, am, _, _) => am,
              orElse: () => null,
            ),
            isLoading: curr.maybeWhen(
              loading: (_, _) => true,
              orElse: () => false,
            ),
          );
          return prevData != currData;
        },
        builder: (context, state) {
          final (month, year) = state.maybeWhen(
            success: (month, year, _, _, _, _) => (month, year),
            loading: (month, year) => (month, year),
            orElse: () => (DateTime.now().month, DateTime.now().year),
          );
          final focusedDay = state.maybeWhen(
            success: (month, year, _, _, _, _) => DateTime(year, month),
            loading: (month, year) => DateTime(year, month),
            orElse: () => DateTime.now(),
          );
          final attendanceMap = state.maybeWhen(
            success: (_, _, _, attendanceMap, _, _) => attendanceMap,
            orElse: () => const <DateTime, AttendanceStatus>{},
          );
          final entityMap = state.maybeWhen(
            success: (_, _, _, _, entityMap, _) => entityMap,
            orElse: () => const <DateTime, AttendanceEntity>{},
          );
          final isLoading = state.maybeWhen(
            loading: (_, _) => true,
            orElse: () => false,
          );

          return RepaintBoundary(
            child: AppFramedContainer(
              backgroundColor: colorScheme.surface,
              margin: EdgeInsets.zero,
              gap: EdgeInsets.zero,
              elevation: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        onPressed: isLoading
                            ? null
                            : () => context.read<MonthlyAttendanceBloc>().add(
                                const MonthlyAttendanceEvent.previousMonthRequested(),
                              ),
                        icon: const Icon(Icons.chevron_left),
                        tooltip: l10n.previousMonth,
                      ),
                      Text(
                        _monthLabel(month, year, locale),
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: .bold,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: isLoading
                            ? null
                            : () => context.read<MonthlyAttendanceBloc>().add(
                                const MonthlyAttendanceEvent.nextMonthRequested(),
                              ),
                        icon: const Icon(Icons.chevron_right),
                        tooltip: l10n.nextMonth,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  AttendanceCalendar(
                    focusedDay: focusedDay,
                    attendanceData: attendanceMap,
                    entityData: entityMap,
                  ),

                  const SizedBox(height: 16),

                  const _AttendanceLegends(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AttendanceLegends extends StatelessWidget {
  const _AttendanceLegends();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final successColor = AppColors.of(context).success;
    final warningColor = AppColors.of(context).warning;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        alignment: WrapAlignment.spaceEvenly,
        children: [
          _LegendItem(dotColor: successColor, label: l10n.present),
          _LegendItem(dotColor: colorScheme.primaryContainer, label: l10n.late),
          _LegendItem(dotColor: warningColor, label: l10n.excused),
          _LegendItem(dotColor: colorScheme.error, label: l10n.absent),
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
        const SizedBox(width: 6),
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
