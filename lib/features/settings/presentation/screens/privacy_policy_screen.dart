// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/settings_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PrivacyPolicyView();
  }
}

class _PrivacyPolicyView extends StatelessWidget {
  const _PrivacyPolicyView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final sections = [
      (title: l10n.privacyDataTitle, body: l10n.privacyDataBody),
      (title: l10n.privacyUsageTitle, body: l10n.privacyUsageBody),
      (title: l10n.privacyStorageTitle, body: l10n.privacyStorageBody),
      (
        title: l10n.privacyNotificationTitle,
        body: l10n.privacyNotificationBody,
      ),
      (title: l10n.privacySharingTitle, body: l10n.privacySharingBody),
      (title: l10n.privacyContactTitle, body: l10n.privacyContactBody),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      appBar: AppTopBar(toolbarHeight: 72, title: Text(l10n.privacyPolicy)),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const .fromLTRB(16, 16, 16, 24),
            sliver: SliverList.list(
              children: [
                Text(
                  l10n.privacyLastUpdated,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  l10n.privacyIntroBody,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                for (final section in sections)
                  _PrivacySectionCard(title: section.title, body: section.body),
              ].separatedBy(16.h),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacySectionCard extends StatelessWidget {
  const _PrivacySectionCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SettingsCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: .w600,
            ),
          ),
          8.h,
          Text(
            body,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
