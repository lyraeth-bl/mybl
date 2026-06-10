// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/notifications/fcm_service.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import 'settings_card.dart';
import 'settings_menu_tile.dart';

class SettingsNotificationSection extends StatefulWidget {
  const SettingsNotificationSection({super.key});

  @override
  State<SettingsNotificationSection> createState() =>
      _SettingsNotificationSectionState();
}

class _SettingsNotificationSectionState
    extends State<SettingsNotificationSection> {
  late Future<bool> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _loadStatus();
  }

  Future<bool> _loadStatus() => di<FCMService>().areNotificationsEnabled();

  void _refreshStatus() {
    if (!mounted) return;
    setState(() {
      _statusFuture = _loadStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: l10n.notifications,
      titleStyle: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SettingsCard(
        padding: EdgeInsets.zero,
        child: FutureBuilder<bool>(
          future: _statusFuture,
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState != ConnectionState.done;
            final isEnabled = snapshot.data ?? false;

            return SettingsMenuTile(
              icon: Icons.notifications_active_outlined,
              iconBackgroundColor: colorScheme.secondaryContainer,
              iconForegroundColor: colorScheme.onSecondaryContainer,
              title: l10n.notificationSettings,
              subtitle: isLoading
                  ? l10n.notificationStatusChecking
                  : isEnabled
                  ? l10n.notificationStatusActive
                  : l10n.notificationStatusInactive,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              trailing: _NotificationStatusBadge(
                isLoading: isLoading,
                isEnabled: isEnabled,
              ),
              onTap: () => _showNotificationSettings(context),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showNotificationSettings(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => const _NotificationSettingsSheet(),
    );

    _refreshStatus();
  }
}

class _NotificationStatusBadge extends StatelessWidget {
  const _NotificationStatusBadge({
    required this.isLoading,
    required this.isEnabled,
  });

  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final backgroundColor = isEnabled
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = isEnabled
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? const SizedBox(
              width: 52,
              height: 28,
            ).toShimmer(context, borderRadius: BorderRadius.circular(999))
          : Container(
              key: ValueKey(isEnabled),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isEnabled
                    ? l10n.notificationStatusActive
                    : l10n.notificationStatusInactive,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}

enum _NotificationSettingsStatus { idle, loading, enabled, denied, failed }

class _NotificationSettingsSheet extends StatefulWidget {
  const _NotificationSettingsSheet();

  @override
  State<_NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState
    extends State<_NotificationSettingsSheet> {
  _NotificationSettingsStatus _status = _NotificationSettingsStatus.idle;

  Future<void> _enableNotifications() async {
    setState(() => _status = _NotificationSettingsStatus.loading);

    final result = await di<FCMService>().activateForAuthenticatedUser();

    if (!mounted) return;

    setState(() {
      _status = switch (result) {
        FCMActivationResult.enabled => _NotificationSettingsStatus.enabled,
        FCMActivationResult.denied => _NotificationSettingsStatus.denied,
        FCMActivationResult.failed => _NotificationSettingsStatus.failed,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isLoading = _status == _NotificationSettingsStatus.loading;
    final content = switch (_status) {
      _NotificationSettingsStatus.idle => (
        icon: Icons.notifications_active_outlined,
        title: l10n.notificationPermissionTitle,
        description: l10n.notificationPermissionDesc,
        buttonLabel: l10n.enableNotifications,
      ),
      _NotificationSettingsStatus.loading => (
        icon: Icons.notifications_outlined,
        title: l10n.notificationPermissionLoadingTitle,
        description: l10n.notificationPermissionLoadingDesc,
        buttonLabel: l10n.enableNotifications,
      ),
      _NotificationSettingsStatus.enabled => (
        icon: Icons.notifications_active,
        title: l10n.notificationPermissionEnabledTitle,
        description: l10n.notificationPermissionEnabledDesc,
        buttonLabel: l10n.close,
      ),
      _NotificationSettingsStatus.denied => (
        icon: Icons.notifications_off_outlined,
        title: l10n.notificationPermissionDeniedTitle,
        description: l10n.notificationPermissionDeniedDesc,
        buttonLabel: l10n.close,
      ),
      _NotificationSettingsStatus.failed => (
        icon: Icons.error_outline,
        title: l10n.notificationPermissionFailedTitle,
        description: l10n.notificationPermissionFailedDesc,
        buttonLabel: l10n.tryAgain,
      ),
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(content.icon, size: 48, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              content.title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ).toShimmer(context, isLoading: isLoading),
            const SizedBox(height: 8),
            Text(
              content.description,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ).toShimmer(context, isLoading: isLoading),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: isLoading
                  ? null
                  : switch (_status) {
                      _NotificationSettingsStatus.idle ||
                      _NotificationSettingsStatus.failed =>
                        _enableNotifications,
                      _ => () => Navigator.of(context).pop(),
                    },
              icon: isLoading
                  ? SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onSurface.withValues(alpha: 0.38),
                      ),
                    )
                  : Icon(
                      _status == _NotificationSettingsStatus.enabled
                          ? Icons.check
                          : Icons.notifications_active_outlined,
                    ),
              label: Text(content.buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
