// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

enum ExtracurricularAttendanceStatus {
  present,
  late,
  excused,
  sick,
  unexcused,
  unknown,
}

ExtracurricularAttendanceStatus extracurricularAttendanceStatusFromRaw(
  String status,
) {
  final normalized = status.toLowerCase().trim();

  if (normalized.contains('hadir') || normalized.contains('present')) {
    return .present;
  }

  if (normalized.contains('terlambat') || normalized.contains('telat')) {
    return .late;
  }

  if (normalized.contains('izin') || normalized.contains('ijin')) {
    return .excused;
  }

  if (normalized.contains('sakit')) return .sick;

  if (normalized.contains('alfa') ||
      normalized.contains('alpa') ||
      normalized.contains('tanpa keterangan')) {
    return .unexcused;
  }

  return .unknown;
}

/// The label for [status], falling back to the raw API value when the status
/// is not one the app recognises.
String extracurricularAttendanceStatusLabel(
  AppLocalizations l10n,
  ExtracurricularAttendanceStatus status,
  String rawStatus,
) {
  return switch (status) {
    .present => l10n.present,
    .late => l10n.late,
    .excused => l10n.excused,
    .sick => l10n.sick,
    .unexcused => l10n.unexcused,
    .unknown =>
      rawStatus.trim().isEmpty ? l10n.noData : rawStatus.capitalizeEveryWord,
  };
}

/// The background and foreground color pair representing [status].
(Color, Color) extracurricularAttendanceStatusColors(
  BuildContext context,
  ExtracurricularAttendanceStatus status,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final appColors = AppColors.of(context);

  return switch (status) {
    .present => (appColors.success.withValues(alpha: 0.12), appColors.success),
    .late => (appColors.warning.withValues(alpha: 0.12), appColors.warning),
    .excused => (
      colorScheme.secondaryContainer,
      colorScheme.onSecondaryContainer,
    ),
    .sick => (colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
    .unexcused => (colorScheme.errorContainer, colorScheme.onErrorContainer),
    .unknown => (
      colorScheme.surfaceContainerHighest,
      colorScheme.onSurfaceVariant,
    ),
  };
}

IconData extracurricularAttendanceStatusIcon(
  ExtracurricularAttendanceStatus status,
) {
  return switch (status) {
    .present => Icons.check_circle_outline_rounded,
    .late => Icons.schedule_rounded,
    .excused => Icons.mail_outline_rounded,
    .sick => Icons.local_hospital_outlined,
    .unexcused => Icons.cancel_outlined,
    .unknown => Icons.help_outline_rounded,
  };
}
