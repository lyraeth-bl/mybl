// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../l10n/app_localizations.dart';

/// A compact coloured label for a request status.
class SarprasStatusBadge extends StatelessWidget {
  const SarprasStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (String label, Color background, Color foreground) = switch (status) {
      'Disetujui' => (
        l10n.sarprasStatusAccepted,
        colors.success.withValues(alpha: 0.15),
        colors.success,
      ),
      'Ditolak' => (
        l10n.sarprasStatusRejected,
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      _ => (
        l10n.sarprasStatusWaiting,
        colors.warning.withValues(alpha: 0.15),
        colors.warning,
      ),
    };

    return AppChipContainer(
      value: label,
      backgroundColor: background,
      foregroundColor: foreground,
    );
  }
}
