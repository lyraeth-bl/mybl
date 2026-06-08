// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../l10n/app_localizations.dart';
import 'academic_result_ui_helpers.dart';

class AcademicResultScoreSummarySection extends StatelessWidget {
  const AcademicResultScoreSummarySection({
    super.key,
    required this.average,
    required this.totalData,
    this.isLoading = false,
  });

  final double average;
  final int totalData;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final clampedAverage = average.clamp(0, 100).toDouble();

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      sliver: SliverToBoxAdapter(
        child: AppContainer(
          margin: EdgeInsets.zero,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          borderRadius: BorderRadius.circular(16),
          elevation: 0,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.currentSemesterScore,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: .bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          academicResultFormatScore(clampedAverage),
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: .bold,
                          ),
                        ).toShimmer(
                          context,
                          isLoading: isLoading,
                          width: 72,
                          height: 32,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            ' / 100',
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: .bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppContainer(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      borderRadius: BorderRadius.circular(999),
                      child:
                          Text(
                            l10n.assessmentDataCount(totalData),
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: .bold,
                            ),
                          ).toShimmer(
                            context,
                            isLoading: isLoading,
                            width: 116,
                            height: 12,
                            borderRadius: BorderRadius.circular(999),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _ScoreProgress(value: clampedAverage, isLoading: isLoading),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreProgress extends StatelessWidget {
  const _ScoreProgress({required this.value, required this.isLoading});

  final double value;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = value / 100;

    return SizedBox.square(
      dimension: 76,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: percent),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
                color: colorScheme.onPrimaryContainer,
                backgroundColor: colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.24,
                ),
              );
            },
          ).toShimmer(
            context,
            isLoading: isLoading,
            width: 76,
            height: 76,
            borderRadius: BorderRadius.circular(999),
          ),
          Center(
            child: Text(
              '${(percent * 100).round()}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: .bold,
              ),
            ).toShimmer(context, isLoading: isLoading, width: 36, height: 14),
          ),
        ],
      ),
    );
  }
}
