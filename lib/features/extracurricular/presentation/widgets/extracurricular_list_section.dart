// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/extracurricular.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSliverGroup(
      title: l10n.extracurricular,
      titleStyle: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      action: AppChipContainer(
        value: l10n.dataCount(extracurricular.length),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: extracurricular.isEmpty
          ? SliverToBoxAdapter(
              child: ExtracurricularMessage(
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final classRoom = '${extracurricular.kelas} ${extracurricular.nomorKelas}'
        .trim();

    return AppContainer(
      margin: const EdgeInsets.only(bottom: 12),
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconContainer(
                icon: Icons.groups_2_outlined,
                padding: const EdgeInsets.all(10),
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      extracurricular.namaKegiatan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      classRoom.isEmpty ? '-' : classRoom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ScoreChip(score: extracurricular.nilai),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.45,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              _DetailTile(
                icon: Icons.badge_outlined,
                label: l10n.nis,
                value: extracurricular.nis,
              ),
              _DetailTile(
                icon: Icons.school_outlined,
                label: l10n.classRoom,
                value: classRoom,
              ),
              _DetailTile(
                icon: Icons.calendar_month_outlined,
                label: l10n.schoolYear,
                value: extracurricular.tajaran,
              ),
              _DetailTile(
                icon: Icons.event_note_outlined,
                label: l10n.semester,
                value: extracurricular.semester,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.score});

  final String score;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppChipContainer(
      backgroundColor: colorScheme.tertiaryContainer,
      foregroundColor: colorScheme.onTertiaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.score,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onTertiaryContainer,
            ),
          ),
          Text(
            score.trim().isEmpty ? '-' : score,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppContainer(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: colorScheme.surfaceContainer,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value.trim().isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExtracurricularMessage extends StatelessWidget {
  const ExtracurricularMessage({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
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
    );
  }
}
