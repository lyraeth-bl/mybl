import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/attendance_summary/attendance_summary.dart';
import '../bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';
import 'attendance_chart.dart';

class AttendanceChartSection extends StatelessWidget {
  const AttendanceChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: l10n.attendanceChart,
      titleStyle: textTheme.titleMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
        buildWhen: (prev, curr) {
          final prevSummary = prev.maybeWhen(
            success: (_, _, _, _, _, s) => s,
            orElse: () => const AttendanceSummary(),
          );
          final currSummary = curr.maybeWhen(
            success: (_, _, _, _, _, s) => s,
            orElse: () => const AttendanceSummary(),
          );
          return prevSummary != currSummary;
        },
        builder: (context, state) {
          final summary = state.maybeWhen(
            success: (_, _, _, _, _, s) => s,
            orElse: () => const AttendanceSummary(),
          );

          return RepaintBoundary(
            child: AppContainer(
              margin: EdgeInsets.zero,
              elevation: 0,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colorScheme.surfaceContainerHighest,
                  offset: const Offset(5, 5),
                ),
              ],
              child: SizedBox(
                height: 250,
                child: AttendanceChart(summary: summary),
              ),
            ),
          );
        },
      ),
    );
  }
}
