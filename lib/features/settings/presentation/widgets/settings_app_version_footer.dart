// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../l10n/app_localizations.dart';

class SettingsAppVersionFooter extends StatelessWidget {
  const SettingsAppVersionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return SliverToBoxAdapter(
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final packageInfo = snapshot.data;
          final version = packageInfo == null
              ? ''
              : '${packageInfo.version}+${packageInfo.buildNumber}';

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      packageInfo?.appName ?? 'MyBL',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ).toShimmer(
                      context,
                      isLoading: packageInfo == null,
                      width: 72,
                      height: 14,
                    ),
                    if (version.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        l10n.appVersion(version),
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  version.isEmpty
                      ? l10n.appVersion('')
                      : l10n.appVersion(version),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                    letterSpacing: 1,
                  ),
                ).toShimmer(
                  context,
                  isLoading: packageInfo == null,
                  width: 96,
                  height: 12,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
