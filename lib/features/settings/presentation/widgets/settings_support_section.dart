// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import 'settings_card.dart';
import 'settings_menu_tile.dart';

class SettingsSupportSection extends StatelessWidget {
  const SettingsSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: l10n.support,
      titleStyle: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      contentPadding: const .symmetric(horizontal: 16, vertical: 8),
      child: SettingsCard(
        padding: .zero,
        child: Column(
          children: [
            SettingsMenuTile(
              icon: Icons.help_outline_rounded,
              iconBackgroundColor: colorScheme.errorContainer,
              iconForegroundColor: colorScheme.onErrorContainer,
              title: l10n.helpCenter,
              onTap: () {},
            ),
            SettingsMenuTile(
              icon: Icons.shield_outlined,
              iconBackgroundColor: colorScheme.secondaryContainer,
              iconForegroundColor: colorScheme.onSecondaryContainer,
              title: l10n.privacyPolicy,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
