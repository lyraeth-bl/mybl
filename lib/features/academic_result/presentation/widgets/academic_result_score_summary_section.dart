// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:my_bl/core/widgets/app_chip_container.dart';

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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final double clampedAverage = average.clamp(0, 100).toDouble();

    return SliverPadding(
      padding: const .fromLTRB(16, 24, 16, 24),
      sliver: SliverToBoxAdapter(
        child: AppFramedContainer(
          margin: .zero,
          gap: .zero,
          elevation: 0,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      l10n.currentSemesterScore,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    8.h,
                    Row(
                      crossAxisAlignment: .end,
                      children: [
                        Text(
                          academicResultFormatScore(clampedAverage),
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ).toShimmer(
                          context,
                          isLoading: isLoading,
                          width: 32,
                          height: 24,
                          borderRadius: .circular(24),
                        ),
                        Padding(
                          padding: const .only(bottom: 4),
                          child: Text(
                            l10n.outOfMaxScore(100),
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    16.h,
                    AppChipContainer.outlined(
                      child: Text(
                        l10n.assessmentDataCount(totalData),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ).toShimmer(
                      context,
                      isLoading: isLoading,
                      width: 120,
                      height: 24,
                      borderRadius: .circular(24),
                    ),
                  ],
                ),
              ),
              16.w,
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final double percent = value / 100;
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);

    return SizedBox.square(
      dimension: 72,
      child: Stack(
        fit: .expand,
        children: [
          disableAnimations
              ? CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 5,
                  strokeCap: .round,
                  color: colorScheme.onSurfaceVariant,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                )
              : TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: percent),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 5,
                      strokeCap: .round,
                      color: colorScheme.onSurfaceVariant,
                      backgroundColor: colorScheme.surfaceContainerHigh,
                    );
                  },
                ),
          Center(
            child:
                Text(
                  academicResultGrade(value),
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ).toShimmer(
                  context,
                  isLoading: isLoading,
                  width: 32,
                  height: 16,
                  borderRadius: .circular(24),
                ),
          ),
        ],
      ),
    );
  }
}
