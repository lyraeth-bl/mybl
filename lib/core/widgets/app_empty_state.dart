// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'app_button.dart';
import 'app_icon_container.dart';

/// A centered icon, title, and message for empty or error states.
///
/// Pass [onRetry] to show a retry action below the message.
@immutable
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  final IconData icon;
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconContainer(
            icon: icon,
            padding: const EdgeInsets.all(18),
            iconSize: 36,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 18),
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            AppButton.outlined(onPressed: onRetry, child: Text(retryLabel!)),
          ],
        ],
      ),
    );
  }
}

/// [AppEmptyState] wrapped in a [SliverFillRemaining], for direct use inside
/// a [CustomScrollView]'s `slivers` list.
@immutable
class AppEmptyStateSliver extends StatelessWidget {
  const AppEmptyStateSliver({
    super.key,
    required this.icon,
    this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  final IconData icon;
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: AppEmptyState(
        icon: icon,
        title: title,
        message: message,
        onRetry: onRetry,
        retryLabel: retryLabel,
      ),
    );
  }
}
