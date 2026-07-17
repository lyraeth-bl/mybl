// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../l10n/app_localizations.dart';

class MenuSheetItem {
  const MenuSheetItem({
    required this.icon,
    required this.label,
    required this.routePath,
  });

  final IconData icon;
  final String label;
  final String routePath;

  static List<MenuSheetItem> menuItems = [
    MenuSheetItem(
      icon: Icons.checklist_rounded,
      label: 'dailyAttendance',
      routePath: RouteNames.attendance,
    ),
    MenuSheetItem(
      icon: Icons.calendar_view_week_rounded,
      label: 'timeTable',
      routePath: RouteNames.timeTable,
    ),
    MenuSheetItem(
      icon: Icons.family_restroom_rounded,
      label: 'guardianDetails',
      routePath: RouteNames.guardianDetails,
    ),
    MenuSheetItem(
      icon: Icons.stars_rounded,
      label: 'meritAndDemerit',
      routePath: RouteNames.meritAndDemerit,
    ),
    MenuSheetItem(
      icon: Icons.event_rounded,
      label: 'academicCalendar',
      routePath: RouteNames.academicCalendar,
    ),
    MenuSheetItem(
      icon: Icons.school_rounded,
      label: 'academicResult',
      routePath: RouteNames.academicResult,
    ),
    MenuSheetItem(
      icon: Icons.emoji_events_rounded,
      label: 'extracurricular',
      routePath: RouteNames.extracurricular,
    ),
    MenuSheetItem(
      icon: Icons.settings_rounded,
      label: 'settings',
      routePath: RouteNames.settings,
    ),
  ];

  String resolveLabel(AppLocalizations l10n) {
    switch (label) {
      case 'dailyAttendance':
        return l10n.dailyAttendance;
      case 'timeTable':
        return l10n.timeTable;
      case 'guardianDetails':
        return l10n.guardianDetails;
      case 'meritAndDemerit':
        return l10n.meritAndDemerit;
      case 'academicCalendar':
        return l10n.academicCalendar;
      case 'academicResult':
        return l10n.academicResult;
      case 'extracurricular':
        return l10n.extracurricularShort;
      case 'settings':
        return l10n.settings;
      default:
        return label;
    }
  }
}
