// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/extracurricular_attendance/extracurricular_attendance.dart';

class ExtracurricularAttendanceFilterSection extends StatelessWidget {
  const ExtracurricularAttendanceFilterSection({
    super.key,
    required this.attendances,
    required this.selectedActivity,
    required this.onChanged,
  });

  final List<ExtracurricularAttendance> attendances;
  final String? selectedActivity;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final activities = _activities;

    return AppSliverGroup(
      title: l10n.activity,
      titleStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      child: SingleChildScrollView(
        scrollDirection: .horizontal,
        child: Row(
          children: [
            _ActivityChip(
              label: l10n.allActivities,
              selected: selectedActivity == null,
              onTap: () => onChanged(null),
            ),
            ...activities.map(
              (activity) => _ActivityChip(
                label: activity,
                selected: selectedActivity == activity,
                onTap: () => onChanged(activity),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> get _activities {
    final activities = attendances
        .map((item) => item.namaKegiatan)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList();
    activities.sort();
    return activities;
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppChipContainer(
      value: label,
      onTap: onTap,
      margin: const .only(right: 8),
      padding: const .symmetric(horizontal: 24, vertical: 16),
      backgroundColor: selected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainer,
      foregroundColor: selected
          ? colorScheme.onPrimaryContainer
          : colorScheme.onSurface,
      side: selected
          ? BorderSide.none
          : BorderSide(color: colorScheme.outlineVariant),
    );
  }
}
