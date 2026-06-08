// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../l10n/app_localizations.dart';

class AcademicResultSemesterFilterSection extends StatelessWidget {
  const AcademicResultSemesterFilterSection({
    super.key,
    required this.selectedSemester,
    required this.onChanged,
    this.isLoading = false,
  });

  final int selectedSemester;
  final ValueChanged<int> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [1, 2].map((semester) {
            return _SemesterChip(
              label: '${l10n.semester} $semester',
              selected: selectedSemester == semester,
              onTap: () => onChanged(semester),
              isLoading: isLoading,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SemesterChip extends StatelessWidget {
  const _SemesterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isLoading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppChipContainer(
      onTap: onTap,
      margin: const EdgeInsetsDirectional.only(end: 10),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      backgroundColor: selected
          ? colorScheme.primary
          : colorScheme.surfaceContainerLow,
      foregroundColor: selected ? colorScheme.onPrimary : colorScheme.onSurface,
      side: selected
          ? BorderSide.none
          : BorderSide(color: colorScheme.outlineVariant),
      child: Text(label).toShimmer(
        context,
        isLoading: isLoading,
        width: 80,
        height: 14,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
