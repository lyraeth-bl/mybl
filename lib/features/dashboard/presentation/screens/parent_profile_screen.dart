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
    return Scaffold(
      appBar: AppTopBar(
        title: Text(AppLocalizations.of(context)!.profile),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.comingSoon,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
