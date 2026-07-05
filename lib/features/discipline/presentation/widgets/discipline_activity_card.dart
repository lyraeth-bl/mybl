// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../l10n/app_localizations.dart';
import 'animated_int_text.dart';
import 'discipline_item.dart';

class DisciplineActivityCard extends StatelessWidget {
  const DisciplineActivityCard({
    super.key,
    required this.item,
    required this.isLoading,
  });

  final DisciplineItem item;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AppColors appColors = AppColors.of(context);
    final Color foregroundColor = item.isMerit
        ? appColors.success
        : colorScheme.error;
    final Color backgroundColor = foregroundColor.withValues(alpha: 0.12);
    final DateFormat formatter = DateFormat(
      'd MMM yyyy',
      Localizations.localeOf(context).toString(),
    );

    return AppContainer(
      margin: const .symmetric(vertical: 8),
      elevation: 0,
      child: Row(
        crossAxisAlignment: .start,
        children: [
          AppIconContainer(
            icon: item.isMerit
                ? Icons.emoji_events_outlined
                : Icons.schedule_rounded,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ).toShimmer(
            context,
            isLoading: isLoading,
            width: 40,
            height: 40,
            borderRadius: .circular(24),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  item.description,
                  maxLines: 4,
                  overflow: .ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ).toShimmer(
                  context,
                  isLoading: isLoading,
                  width: 160,
                  height: 16,
                  borderRadius: .circular(24),
                ),
                8.h,
                Text(
                  '${l10n.teacher}: ${item.teacherName}',
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ).toShimmer(
                  context,
                  isLoading: isLoading,
                  width: 120,
                  height: 8,
                  borderRadius: .circular(24),
                ),
                16.h,
                Text(
                  formatter.format(item.date.toLocal()),
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ).toShimmer(
                  context,
                  isLoading: isLoading,
                  width: 120,
                  height: 8,
                  borderRadius: .circular(24),
                ),
              ],
            ),
          ),
          AnimatedIntText(
            value: item.point,
            builder: (context, value) {
              return Text(
                '${item.isMerit ? '+' : '-'}$value',
                style: textTheme.titleSmall?.copyWith(color: foregroundColor),
              );
            },
          ).toShimmer(
            context,
            isLoading: isLoading,
            width: 24,
            height: 16,
            borderRadius: .circular(24),
          ),
        ].separatedBy(16.w),
      ),
    );
  }
}
