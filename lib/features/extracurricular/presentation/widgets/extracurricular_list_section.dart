// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/extracurricular.dart';
import '../extracurricular_activity_icon.dart';

class ExtracurricularListSection extends StatelessWidget {
  const ExtracurricularListSection({
    super.key,
    required this.extracurricular,
    required this.emptyMessage,
  });

  final List<ExtracurricularEntity> extracurricular;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: l10n.extracurricular,
      titleStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      action: AppChipContainer.outlined(
        value: l10n.dataCount(extracurricular.length),
      ),
      sliver: extracurricular.isEmpty
          ? SliverToBoxAdapter(
              child: AppEmptyState(
                icon: Icons.assignment_outlined,
                message: emptyMessage,
              ),
            )
          : SliverList.list(
              children: extracurricular
                  .map((item) => _ExtracurricularCard(extracurricular: item))
                  .toList()
                  .makeListAnimate(),
            ),
    );
  }
}

class _ExtracurricularCard extends StatelessWidget {
  const _ExtracurricularCard({required this.extracurricular});

  final ExtracurricularEntity extracurricular;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    return AppFramedContainer(
      margin: const .only(bottom: 12),
      elevation: 0,
      gap: .zero,
      child: ListTile(
        contentPadding: .zero,
        leading: AppIconContainer(
          icon: extracurricular.activityIcon,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
        title: Text(
          extracurricular.namaKegiatan,
          maxLines: 2,
          overflow: .ellipsis,
          style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
        ),
        trailing: _ScoreChip(score: extracurricular.nilai),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.score});

  final String score;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Text(
      score.trim().isEmpty ? '-' : score,
      style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
    );
  }
}
