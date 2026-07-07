// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_notification/app_notification.dart';
import 'notification_helpers.dart';

class NotificationSliverGroup extends StatelessWidget {
  const NotificationSliverGroup({
    super.key,
    required this.group,
    required this.onNotificationTap,
    required this.onMarkAllAsRead,
  });

  final NotificationGroup group;
  final ValueChanged<AppNotification> onNotificationTap;
  final ValueChanged<List<AppNotification>> onMarkAllAsRead;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final hasUnread = group.items.any((item) => !notificationIsRead(item));

    return AppSliverGroup(
      title: group.title,
      action: hasUnread
          ? AppChipContainer(
              value: l10n.markAllAsRead,
              onTap: () => onMarkAllAsRead(group.items),
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
            )
          : null,
      pinned: true,
      backgroundColor: colorScheme.surface,
      titleStyle: textTheme.titleSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: .bold,
      ),
      headerPadding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
      headerHeight: 48,
      titleOffset: 0,
      collapsedOpacity: 1,
      contentPadding: const .symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList.list(
        children: group.items
            .map(
              (notification) => _NotificationCard(
                notification: notification,
                onTap: () => onNotificationTap(notification),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final isRead = notificationIsRead(notification);
    final icon = notificationIconForType(notification.type);

    return AppContainer(
      margin: const .only(bottom: 10),
      backgroundColor: isRead
          ? colorScheme.surfaceContainerLow
          : colorScheme.primaryContainer.withValues(alpha: 0.2),
      foregroundColor: isRead
          ? colorScheme.onSurface
          : colorScheme.onPrimaryContainer,
      elevation: 0,
      borderRadius: .circular(16),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: .start,
        children: [
          _NotificationLeadingIcon(
            icon: icon,
            imageUrl: notification.imageUrl,
            isRead: isRead,
          ),
          16.w,
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  crossAxisAlignment: .start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        maxLines: 2,
                        overflow: .ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: isRead ? .w400 : .bold,
                        ),
                      ),
                    ),
                    if (!isRead) ...[8.w, _UnreadBadge(label: l10n.unread)],
                  ],
                ),
                8.h,
                Text(
                  notification.body,
                  maxLines: 3,
                  overflow: .ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.25,
                  ),
                ),
                16.h,
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    8.w,
                    Expanded(
                      child: Text(
                        formatNotificationTime(notification.sentAt, locale),
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationLeadingIcon extends StatelessWidget {
  const _NotificationLeadingIcon({
    required this.icon,
    required this.imageUrl,
    required this.isRead,
  });

  final IconData icon;
  final String? imageUrl;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = isRead
        ? colorScheme.onSurfaceVariant
        : colorScheme.onPrimaryContainer;
    final backgroundColor = isRead
        ? colorScheme.surfaceContainerHighest
        : colorScheme.primaryContainer;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(borderRadius: .circular(8)),
      clipBehavior: .antiAlias,
      child: imageUrl == null || imageUrl!.isEmpty
          ? AppIconContainer(
              icon: icon,
              padding: const .all(12),
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shape: RoundedRectangleBorder(borderRadius: .circular(8)),
            )
          : Image.network(
              imageUrl!,
              fit: .cover,
              errorBuilder: (context, error, stackTrace) => AppIconContainer(
                icon: icon,
                padding: const .all(12),
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                shape: RoundedRectangleBorder(borderRadius: .circular(8)),
              ),
            ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppChipContainer(
      value: label,
      constraints: const BoxConstraints(maxWidth: 96),
      padding: const .symmetric(horizontal: 8, vertical: 4),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      textStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: .bold,
      ),
    );
  }
}
