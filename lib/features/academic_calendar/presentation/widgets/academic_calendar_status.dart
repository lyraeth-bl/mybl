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
    return .holiday;
  }

  if (normalized.contains('asas') ||
      normalized.contains('ujian') ||
      normalized.contains('pts') ||
      normalized.contains('pas') ||
      normalized.contains('pat') ||
      normalized.contains('asat')) {
    return .exam;
  }

  if (normalized.contains('class meeting') ||
      normalized.contains('class metting') ||
      normalized.contains('event') ||
      normalized.contains('kegiatan') ||
      normalized.contains('perayaan')) {
    return .event;
  }

  if (normalized.contains('rapor') ||
      normalized.contains('raport') ||
      normalized.contains('pembagian')) {
    return .academic;
  }

  return .academic;
}

AcademicCalendarStatus academicCalendarStatusFromEvents(
  List<AcademicCalendarEntity> events,
) {
  if (events.any(
    (event) => academicCalendarStatusFromTitle(event.judul) == .holiday,
  )) {
    return .holiday;
  }

  if (events.any(
    (event) => academicCalendarStatusFromTitle(event.judul) == .exam,
  )) {
    return .exam;
  }

  if (events.any(
    (event) => academicCalendarStatusFromTitle(event.judul) == .event,
  )) {
    return .event;
  }

  return .academic;
}

String academicCalendarStatusLabel(
  AppLocalizations l10n,
  AcademicCalendarStatus status,
) {
  return switch (status) {
    .exam => l10n.exam,
    .academic => l10n.academic,
    .holiday => l10n.holiday,
    .event => l10n.event,
  };
}

(Color, Color) academicCalendarStatusColors(
  BuildContext context,
  AcademicCalendarStatus status,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final appColors = AppColors.of(context);

  return switch (status) {
    .exam => (colorScheme.primaryContainer, colorScheme.onPrimaryContainer),
    .academic => (
      colorScheme.tertiaryContainer,
      colorScheme.onTertiaryContainer,
    ),
    .holiday => (colorScheme.errorContainer, colorScheme.onErrorContainer),
    .event => (
      appColors.warning.withValues(alpha: 0.18),
      colorScheme.onSurface,
    ),
  };
}

/// A solid, equally-saturated color representing [status] for use in
/// legends/swatches, distinct from the pale container tones used for day
/// cell backgrounds.
Color academicCalendarStatusDotColor(
  BuildContext context,
  AcademicCalendarStatus status,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final appColors = AppColors.of(context);

  return switch (status) {
    .exam => colorScheme.primary,
    .academic => colorScheme.tertiary,
    .holiday => colorScheme.error,
    .event => appColors.warning,
  };
}
