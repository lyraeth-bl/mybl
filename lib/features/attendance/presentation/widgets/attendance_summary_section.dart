import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/attendance_summary/attendance_summary.dart';
import '../bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';

class AttendanceSummarySection extends StatelessWidget {
  const AttendanceSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
      buildWhen: (prev, curr) {
        final prevData = (
          isLoading: prev.maybeWhen(
            loading: (_, _) => true,
            orElse: () => false,
          ),
          summary: prev.maybeWhen(
            success: (_, _, _, _, _, s) => s,
            orElse: () => const AttendanceSummary(),
          ),
        );
        final currData = (
          isLoading: curr.maybeWhen(
            loading: (_, _) => true,
            orElse: () => false,
          ),
          summary: curr.maybeWhen(
            success: (_, _, _, _, _, s) => s,
            orElse: () => const AttendanceSummary(),
          ),
        );
        return prevData != currData;
      },
      builder: (context, state) {
        final summary = state.maybeWhen(
          success: (_, _, _, _, _, summary) => summary,
          orElse: () => const AttendanceSummary(),
        );
        final isLoading = state.maybeWhen(
          loading: (_, _) => true,
          orElse: () => false,
        );

        final cards = [
          (label: l10n.present, value: summary.present),
          (label: l10n.late, value: summary.late),
          (label: l10n.excused, value: summary.excused),
          (label: l10n.absent, value: summary.absent),
        ];
        final rate = summary.attendanceRate;
        final percent = '${(rate * 100).toStringAsFixed(0)}%';

        return AppSliverGroup(
          title: l10n.attendanceSummary,
          titleStyle: textTheme.titleMedium!.copyWith(
            color: colorScheme.onSurface,
            fontWeight: .bold,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: AppContainer(
            margin: EdgeInsets.zero,
            elevation: 0,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.surfaceContainerHighest,
                offset: const Offset(5, 5),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.thisMonthlyAttendance,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      percent,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: rate),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (_, value, _) =>
                      // ignore: deprecated_member_use
                      LinearProgressIndicator(value: value, year2023: false),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 85,
                  width: double.infinity,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          final shape = index.makeHorizontalGoogleShape(
                            cards.length - 1,
                          );

                          return SizedBox(
                            width: constraints.maxWidth / cards.length,
                            child: _AttendanceSummaryCard(
                              label: card.label,
                              value: card.value.toString(),
                              shapeBorder: shape,
                              isLoading: isLoading,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AttendanceSummaryCard extends StatelessWidget {
  const _AttendanceSummaryCard({
    required this.label,
    required this.value,
    required this.isLoading,
    this.shapeBorder,
  });

  final String label;
  final String value;
  final bool isLoading;
  final ShapeBorder? shapeBorder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppContainer(
      backgroundColor: colorScheme.surfaceContainerLow,
      margin: EdgeInsets.symmetric(horizontal: 2),
      shape: shapeBorder,
      borderRadius: null,
      elevation: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child:
                Text(
                  value,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ).toShimmer(
                  context,
                  alignment: Alignment.center,
                  width: 24,
                  height: 28,
                  isLoading: isLoading,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
