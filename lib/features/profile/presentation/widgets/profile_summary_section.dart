// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../academic_result/presentation/bloc/academic_result_bloc.dart';
import '../../../attendance/presentation/bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';
import '../../../discipline/presentation/bloc/merit_bloc/merit_bloc.dart';

class ProfileSummarySection extends StatelessWidget {
  const ProfileSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const .fromLTRB(16, 0, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            const _TotalMeritCard(),
            12.h,
            Row(
              children: [
                const Expanded(child: _AttendanceSummaryCard()),
                16.w,
                const Expanded(child: _ScoreSummaryCard()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalMeritCard extends StatelessWidget {
  const _TotalMeritCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return BlocSelector<MeritBloc, MeritState, int?>(
      selector: (state) => state.maybeWhen(
        success: (listMerit) =>
            listMerit.fold<int>(0, (total, merit) => total + merit.point),
        emptyData: () => 0,
        orElse: () => null,
      ),
      builder: (context, totalMeritPoint) {
        final value = totalMeritPoint == null
            ? '-'
            : NumberFormat.decimalPattern(locale).format(totalMeritPoint);

        return AppContainer(
          margin: .zero,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          borderRadius: .circular(16),
          elevation: 0,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      l10n.totalMeritPoint,
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: .bold,
                        letterSpacing: 0,
                      ),
                    ),
                    8.h,
                    Text(
                      value,
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: .bold,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              16.w,
              AppIconContainer(
                icon: Icons.workspace_premium_outlined,
                iconSize: 32,
                padding: const .all(16),
                backgroundColor: colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.14,
                ),
                foregroundColor: colorScheme.onPrimaryContainer,
                shape: RoundedRectangleBorder(borderRadius: .circular(16)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AttendanceSummaryCard extends StatelessWidget {
  const _AttendanceSummaryCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<MonthlyAttendanceBloc, MonthlyAttendanceState, double?>(
      selector: (state) => state.maybeWhen(
        success: (_, _, _, _, _, summary) => summary.attendanceRate,
        orElse: () => null,
      ),
      builder: (context, attendanceRate) {
        final rate = (attendanceRate ?? 0).clamp(0.0, 1.0);
        final value = attendanceRate == null
            ? '-'
            : '${(rate * 100).toStringAsFixed(1)}%';

        return _ProfileMetricCard(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              SizedBox.square(
                dimension: 72,
                child: Stack(
                  fit: .expand,
                  children: [
                    CircularProgressIndicator(
                      value: rate,
                      strokeWidth: 6,
                      strokeCap: .round,
                      color: colorScheme.primary,
                      backgroundColor: colorScheme.primaryContainer,
                    ),
                    Center(
                      child: Text(
                        value,
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: .bold,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              16.h,
              Flexible(
                child: Text(
                  l10n.profileAttendance,
                  maxLines: 1,
                  overflow: .ellipsis,
                  textAlign: .center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: .w500,
                    letterSpacing: 0,
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

class _ScoreSummaryCard extends StatelessWidget {
  const _ScoreSummaryCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return BlocSelector<AcademicResultBloc, AcademicResultState, double?>(
      selector: (state) => state.maybeWhen(
        success: (academicResult) =>
            academicResult.data.overallSummaryResult.average,
        orElse: () => null,
      ),
      builder: (context, average) {
        final value = average == null
            ? '-'
            : NumberFormat('0.#', locale).format(average);

        return _ProfileMetricCard(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              AppIconContainer(
                icon: Icons.star_border_rounded,
                iconSize: 34,
                padding: const .all(8),
                backgroundColor: colorScheme.tertiaryContainer,
                foregroundColor: colorScheme.onTertiaryContainer,
              ),
              12.h,
              Flexible(
                child: FittedBox(
                  fit: .scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    textAlign: .center,
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: .bold,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              4.h,
              Flexible(
                child: Text(
                  l10n.profileAverageScore,
                  maxLines: 1,
                  overflow: .ellipsis,
                  textAlign: .center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0,
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

class _ProfileMetricCard extends StatelessWidget {
  const _ProfileMetricCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: .zero,
      backgroundColor: colorScheme.surfaceContainerLow,
      borderRadius: .circular(16),
      elevation: 0,
      child: SizedBox(height: 128, child: child),
    );
  }
}
