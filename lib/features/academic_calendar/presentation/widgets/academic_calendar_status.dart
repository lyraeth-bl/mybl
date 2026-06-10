// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/academic_calendar_entity.dart';

enum AcademicCalendarStatus { exam, academic, holiday, event }

AcademicCalendarStatus academicCalendarStatusFromTitle(String title) {
  final normalized = title.toLowerCase();

  if (normalized.contains('libur') || normalized.contains('natal')) {
    return AcademicCalendarStatus.holiday;
  }

  if (normalized.contains('asas') ||
      normalized.contains('ujian') ||
      normalized.contains('pts') ||
      normalized.contains('pas') ||
      normalized.contains('pat') ||
      normalized.contains('asat')) {
    return AcademicCalendarStatus.exam;
  }

  if (normalized.contains('class meeting') ||
      normalized.contains('event') ||
      normalized.contains('kegiatan') ||
      normalized.contains('perayaan')) {
    return AcademicCalendarStatus.event;
  }

  if (normalized.contains('rapor') ||
      normalized.contains('raport') ||
      normalized.contains('pembagian')) {
    return AcademicCalendarStatus.academic;
  }

  return AcademicCalendarStatus.academic;
}

AcademicCalendarStatus academicCalendarStatusFromEvents(
  List<AcademicCalendarEntity> events,
) {
  if (events.any(
    (event) =>
        academicCalendarStatusFromTitle(event.judul) ==
        AcademicCalendarStatus.holiday,
  )) {
    return AcademicCalendarStatus.holiday;
  }

  if (events.any(
    (event) =>
        academicCalendarStatusFromTitle(event.judul) ==
        AcademicCalendarStatus.exam,
  )) {
    return AcademicCalendarStatus.exam;
  }

  if (events.any(
    (event) =>
        academicCalendarStatusFromTitle(event.judul) ==
        AcademicCalendarStatus.event,
  )) {
    return AcademicCalendarStatus.event;
  }

  return AcademicCalendarStatus.academic;
}

String academicCalendarStatusLabel(
  AppLocalizations l10n,
  AcademicCalendarStatus status,
) {
  return switch (status) {
    AcademicCalendarStatus.exam => l10n.exam,
    AcademicCalendarStatus.academic => l10n.academic,
    AcademicCalendarStatus.holiday => l10n.holiday,
    AcademicCalendarStatus.event => l10n.event,
  };
}

(Color, Color) academicCalendarStatusColors(
  BuildContext context,
  AcademicCalendarStatus status,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final appColors = AppColors.of(context);

  return switch (status) {
    AcademicCalendarStatus.exam => (
      colorScheme.primaryContainer,
      colorScheme.onPrimaryContainer,
    ),
    AcademicCalendarStatus.academic => (
      colorScheme.tertiaryContainer,
      colorScheme.onTertiaryContainer,
    ),
    AcademicCalendarStatus.holiday => (
      colorScheme.errorContainer,
      colorScheme.onErrorContainer,
    ),
    AcademicCalendarStatus.event => (
      appColors.warning.withValues(alpha: 0.18),
      appColors.warning,
    ),
  };
}
