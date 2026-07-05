// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../l10n/app_localizations.dart';
import 'animated_int_text.dart';

class DisciplineSummarySection extends StatelessWidget {
  const DisciplineSummarySection({
    super.key,
    required this.meritPoint,
    required this.demeritPoint,
    required this.isLoading,
  });

  final int meritPoint;
  final int demeritPoint;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppColors appColors = AppColors.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final disciplinePoint = (100 + meritPoint - demeritPoint)
        .clamp(0, 100)
        .toInt();
    final statusColor = _statusColor(
      colorScheme: colorScheme,
      appColors: appColors,
      point: disciplinePoint,
    );

    return SliverPadding(
      padding: const .fromLTRB(16, 24, 16, 16),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            AppFramedContainer(
              gap: .zero,
              margin: .zero,
              elevation: 0,
              child: Column(
                children: [
                  Text(
                    l10n.point,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  8.h,
                  Row(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .end,
                    children: [
                      AnimatedIntText(
                        value: disciplinePoint,
                        builder: (context, value) {
                          return Text(
                            '$value',
                            style: textTheme.displaySmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: .bold,
                            ),
                          );
                        },
                      ).toShimmer(
                        context,
                        isLoading: isLoading,
                        width: 64,
                        height: 40,
                        borderRadius: .circular(24),
                      ),
                      Padding(
                        padding: const .only(bottom: 8),
                        child: Text(
                          ' / 100',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  16.h,
                  ClipRRect(
                    borderRadius: .circular(24),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: disciplinePoint / 100,
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          minHeight: 8,
                          value: value,
                          color: statusColor,
                          backgroundColor: colorScheme.surfaceContainer,
                          // ignore: deprecated_member_use
                          year2023: false,
                        );
                      },
                    ),
                  ).toShimmer(
                    context,
                    isLoading: isLoading,
                    width: double.infinity,
                    height: 8,
                    borderRadius: .circular(24),
                  ),
                  16.h,
                  Text(
                    _statusText(l10n, disciplinePoint),
                    textAlign: .center,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ).toShimmer(
                    context,
                    isLoading: isLoading,
                    width: 160,
                    height: 8,
                    borderRadius: .circular(24),
                  ),
                ],
              ),
            ),
            16.h,
            Row(
              children: [
                Expanded(
                  child: _DisciplineStatCard(
                    label: l10n.merit,
                    point: meritPoint,
                    isMerit: true,
                    isLoading: isLoading,
                  ),
                ),
                Expanded(
                  child: _DisciplineStatCard(
                    label: l10n.demerit,
                    point: demeritPoint,
                    isMerit: false,
                    isLoading: isLoading,
                  ),
                ),
              ].separatedBy(16.w),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor({
    required ColorScheme colorScheme,
    required AppColors appColors,
    required int point,
  }) {
    if (point >= 80) return appColors.success;
    if (point >= 60) return appColors.warning;
    return colorScheme.error;
  }

  String _statusText(AppLocalizations l10n, int point) {
    if (point >= 100) return l10n.disciplineStatusExcellent;
    if (point >= 80) return l10n.disciplineStatusGood;
    if (point >= 60) return l10n.disciplineStatusNeedsAttention;
    return l10n.disciplineStatusCritical;
  }
}

class _DisciplineStatCard extends StatelessWidget {
  const _DisciplineStatCard({
    required this.label,
    required this.point,
    required this.isMerit,
    required this.isLoading,
  });

  final String label;
  final int point;
  final bool isMerit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppColors appColors = AppColors.of(context);
    final Color foregroundColor = isMerit
        ? appColors.success
        : colorScheme.error;
    final Color backgroundColor = foregroundColor.withValues(alpha: 0.12);

    return AppFramedContainer(
      margin: .zero,
      gap: .zero,
      elevation: 0,
      child: Column(
        children: [
          AppIconContainer(
            icon: isMerit ? Icons.emoji_events_outlined : Icons.warning_rounded,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
          16.h,
          Text(
            label,
            maxLines: 1,
            overflow: .ellipsis,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: .bold,
            ),
          ),
          8.h,
          AnimatedIntText(
            value: point,
            builder: (context, value) {
              return Text(
                '${isMerit ? '+' : '-'}$value ${l10nPointLabel(context)}',
                maxLines: 1,
                overflow: .ellipsis,
                style: textTheme.titleLarge?.copyWith(color: foregroundColor),
              );
            },
          ).toShimmer(
            context,
            isLoading: isLoading,
            width: 80,
            height: 24,
            borderRadius: .circular(24),
          ),
        ],
      ),
    );
  }

  String l10nPointLabel(BuildContext context) =>
      AppLocalizations.of(context)!.point;
}
