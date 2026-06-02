// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/constants/constant.dart';
import '../../../../l10n/app_localizations.dart';

class TimeTableDaySelectorSection extends StatelessWidget {
  const TimeTableDaySelectorSection({
    super.key,
    required this.selectedDay,
    required this.onSelected,
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

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 64,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: defaultDayValues.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final day = defaultDayValues[index];

            return ChoiceChip(
              shape: RoundedRectangleBorder(borderRadius: customRadius),
              label: Text(_localizedDay(context, day)),
              selected: day == selectedDay,
              onSelected: (_) => onSelected(day),
            );
          },
        ),
      ),
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
