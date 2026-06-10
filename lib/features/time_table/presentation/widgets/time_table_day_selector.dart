// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';

class TimeTableDaySelectorSection extends StatelessWidget {
  const TimeTableDaySelectorSection({
    super.key,
    required this.selectedDay,
    required this.onSelected,
    required this.sliver,
  });

  static const String monday = 'Senin';
  static const String tuesday = 'Selasa';
  static const String wednesday = 'Rabu';
  static const String thursday = 'Kamis';
  static const String friday = 'Jumat';
  static const String saturday = 'Sabtu';
  static const String sunday = 'Minggu';

  static const List<String> defaultDayValues = [
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday,
  ];

  final String selectedDay;
  final ValueChanged<String> onSelected;
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSliverGroup(
      title: '',
      pinned: true,
      headerHeight: 64,
      headerPadding: EdgeInsets.zero,
      backgroundColor: colorScheme.surface,
      titleOffset: 0,
      collapsedOpacity: 1,
      action: SizedBox(
        width: MediaQuery.sizeOf(context).width - 8,
        height: 64,
        child: _TimeTableDaySelector(
          selectedDay: selectedDay,
          onSelected: onSelected,
          localizedDay: (day) => _localizedDay(context, day),
        ),
      ),
      sliver: sliver,
    );
  }

  String _localizedDay(BuildContext context, String day) {
    final l10n = AppLocalizations.of(context)!;

    return switch (day) {
      monday => l10n.monday,
      tuesday => l10n.tuesday,
      wednesday => l10n.wednesday,
      thursday => l10n.thursday,
      friday => l10n.friday,
      saturday => l10n.saturday,
      sunday => l10n.sunday,
      _ => day,
    };
  }
}

class _TimeTableDaySelector extends StatelessWidget {
  const _TimeTableDaySelector({
    required this.selectedDay,
    required this.onSelected,
    required this.localizedDay,
  });

  final String selectedDay;
  final ValueChanged<String> onSelected;
  final String Function(String day) localizedDay;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 10, 16, 10),
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: TimeTableDaySelectorSection.defaultDayValues.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final day = TimeTableDaySelectorSection.defaultDayValues[index];

        return ChoiceChip(
          label: Text(localizedDay(day)),
          selected: day == selectedDay,
          onSelected: (_) => onSelected(day),
        );
      },
    );
  }
}
