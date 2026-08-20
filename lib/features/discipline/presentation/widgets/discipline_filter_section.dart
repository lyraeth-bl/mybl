// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import 'animated_int_text.dart';

class DisciplineFilterGroup extends StatelessWidget {
  const DisciplineFilterGroup({
    super.key,
    required this.schoolSessions,
    required this.semesters,
    required this.selectedSchoolSession,
    required this.selectedSemester,
    required this.onSchoolSessionChanged,
    required this.onSemesterChanged,
    required this.activityCount,
    required this.isLoading,
    required this.sliver,
  });

  final List<String> schoolSessions;
  final List<String> semesters;
  final String selectedSchoolSession;
  final String selectedSemester;
  final ValueChanged<String> onSchoolSessionChanged;
  final ValueChanged<String> onSemesterChanged;
  final int activityCount;
  final bool isLoading;
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: '',
      pinned: true,
      headerHeight: 72,
      headerPadding: .zero,
      backgroundColor: colorScheme.surfaceContainer,
      titleOffset: 0,
      collapsedOpacity: 1,
      action: SizedBox(
        width: MediaQuery.sizeOf(context).width - 8,
        height: 72,
        child: Row(
          children: [
            Expanded(
              child: _FilterChipButton(
                label: selectedSchoolSession.isEmpty
                    ? l10n.schoolYear
                    : selectedSchoolSession,
                onTap: () => _showFilterSheet(
                  context: context,
                  title: l10n.schoolYear,
                  labelOf: (value) => value,
                  values: schoolSessions,
                  selectedValue: selectedSchoolSession,
                  onChanged: onSchoolSessionChanged,
                ),
                margin: .only(left: 8),
                isLoading: isLoading,
              ),
            ),
            Expanded(
              child: _FilterChipButton(
                label: selectedSemester.isEmpty
                    ? l10n.semester
                    : '${l10n.semester} $selectedSemester',
                onTap: () => _showFilterSheet(
                  context: context,
                  title: l10n.semester,
                  labelOf: (value) => '${l10n.semester} $value',
                  values: semesters,
                  selectedValue: selectedSemester,
                  onChanged: onSemesterChanged,
                ),
                margin: .only(right: 16),
                isLoading: isLoading,
              ),
            ),
          ].separatedBy(16.w),
        ),
      ),
      sliver: AppSliverGroup(
        headerPadding: .zero,
        contentPadding: .zero,
        title: l10n.disciplineActivityLog,
        headerHeight: 52,
        titleOffset: 0,
        collapsedOpacity: 1,
        action: AppChipContainer.outlined(
          child:
              AnimatedIntText(
                value: activityCount,
                builder: (context, value) => Text(l10n.dataCount(value)),
              ).toShimmer(
                context,
                isLoading: isLoading,
                width: 48,
                height: 12,
                borderRadius: .circular(24),
              ),
        ),
        sliver: sliver,
      ),
    );
  }

  Future<void> _showFilterSheet({
    required BuildContext context,
    required String title,
    required String Function(String value) labelOf,
    required List<String> values,
    required String selectedValue,
    required ValueChanged<String> onChanged,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => _FilterSheet(
        title: title,
        labelOf: labelOf,
        values: values,
        selectedValue: selectedValue,
      ),
    );

    if (selected == null) return;
    onChanged(selected);
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.onTap,
    required this.margin,
    required this.isLoading,
  });

  final String label;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppChipContainer(
      onTap: isLoading ? null : onTap,
      margin: margin,
      constraints: const BoxConstraints(minHeight: 48),
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      child: Row(
        mainAxisAlignment: .center,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: .ellipsis,
              textAlign: .center,
            ),
          ),
          const Icon(Icons.expand_more_rounded, size: 16),
        ],
      ),
    ).toShimmer(
      context,
      isLoading: isLoading,
      height: 48,
      borderRadius: .circular(24),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.title,
    required this.labelOf,
    required this.values,
    required this.selectedValue,
  });

  final String title;
  final String Function(String value) labelOf;
  final List<String> values;
  final String selectedValue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return SafeArea(
      child: Padding(
        padding: const .only(bottom: 8),
        child: Column(
          mainAxisSize: .min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Align(
                alignment: .centerLeft,
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            ...values.map(
              (value) => ListTile(
                leading: Icon(
                  selectedValue == value
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(labelOf(value)),
                onTap: () => Navigator.of(context).pop(value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
