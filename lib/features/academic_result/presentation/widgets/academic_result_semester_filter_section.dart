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
        scrollDirection: .horizontal,
        padding: const .fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [1, 2]
              .map((semester) {
                return _SemesterChip(
                  label: '${l10n.semester} $semester',
                  selected: selectedSemester == semester,
                  onTap: () => onChanged(semester),
                  isLoading: isLoading,
                ).toShimmer(
                  context,
                  isLoading: isLoading,
                  height: 48,
                  width: 80,
                  borderRadius: .circular(24),
                );
              })
              .toList()
              .separatedBy(8.w),
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return AppChipContainer(
      onTap: onTap,
      padding: const .symmetric(horizontal: 16, vertical: 8),
      constraints: const BoxConstraints(minHeight: 48),
      backgroundColor: selected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainer,
      foregroundColor: selected
          ? colorScheme.onPrimaryContainer
          : colorScheme.onSurface,
      side: selected
          ? BorderSide.none
          : BorderSide(color: colorScheme.outlineVariant),
      child: Center(child: Text(label)),
    );
  }
}
