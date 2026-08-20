// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import 'app_toast.dart';

/// Full-screen notice shown when the installed build is too old to keep using.
///
/// [downloadLink] comes from the backend and may be missing or a placeholder,
/// in which case the notice explains where to ask instead of offering a button
/// that goes nowhere.
class AppUpdateRequiredContainer extends StatelessWidget {
  const AppUpdateRequiredContainer({super.key, this.downloadLink});

  final String? downloadLink;

  Uri? get _uri {
    final link = downloadLink?.trim() ?? '';
    if (link.isEmpty || link == '-') return null;

    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasScheme) return null;

    return uri;
  }

  Future<void> _openDownload(BuildContext context, Uri uri) async {
    final l10n = AppLocalizations.of(context)!;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      AppToast.error(context, l10n.updateOpenFailed, showProgressBar: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final uri = _uri;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      color: colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.system_update_rounded,
              size: 80,
              color: colorScheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            l10n.updateRequired,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            uri == null ? l10n.updateLinkUnavailable : l10n.updateRequiredDesc,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          if (uri != null) ...[
            const SizedBox(height: 40),

            FilledButton(
              onPressed: () => _openDownload(context, uri),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.updateNow),
            ),
          ],
        ],
      ),
    );
  }
}
