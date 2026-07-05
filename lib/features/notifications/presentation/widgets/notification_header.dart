// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class NotificationHeader extends StatelessWidget {
  const NotificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SliverAppBar.medium(
      title: Text(
        l10n.notifications,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: colorScheme.primaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      centerTitle: true,
      floating: false,
      pinned: true,
    );
  }
}
