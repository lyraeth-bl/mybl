// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/extracurricular.dart';

class ExtracurricularFilterSection extends StatelessWidget {
  const ExtracurricularFilterSection({
    super.key,
    required this.extracurricular,
    required this.selectedSchoolYear,
    required this.onChanged,
  });

  final List<ExtracurricularEntity> extracurricular;
  final String? selectedSchoolYear;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final schoolYears = _schoolYears;

    return AppSliverGroup(
      title: l10n.schoolYear,
      titleStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      child: SingleChildScrollView(
        scrollDirection: .horizontal,
        child: Row(
          children: [
            _SchoolYearChip(
              label: l10n.allSchoolYears,
              selected: selectedSchoolYear == null,
              onTap: () => onChanged(null),
            ),
            ...schoolYears.map(
              (schoolYear) => _SchoolYearChip(
                label: schoolYear,
                selected: selectedSchoolYear == schoolYear,
                onTap: () => onChanged(schoolYear),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> get _schoolYears {
    final years = extracurricular
        .map((item) => item.tajaran)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }
}

class _SchoolYearChip extends StatelessWidget {
  const _SchoolYearChip({
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
