// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppTopBar(
        backgroundColor: colorScheme.surfaceContainerLow,
        title: Text(l10n.profile),
      ),
      backgroundColor: colorScheme.surfaceContainer,
      body: Center(
        child: Text(
          l10n.comingSoon,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
