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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool hasUnread = group.items.any((item) => !notificationIsRead(item));

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
      backgroundColor: colorScheme.surfaceContainer,
      titleStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      headerHeight: 56,
      titleOffset: 0,
      collapsedOpacity: 1,
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).toString();
    final bool isRead = notificationIsRead(notification);
    final IconData icon = notificationIconForType(notification.type);

    final content = _NotificationCardContent(
      notification: notification,
      icon: icon,
      isRead: isRead,
      locale: locale,
      colorScheme: colorScheme,
      textTheme: textTheme,
      l10n: l10n,
    );

    return isRead
        ? AppContainer(
            margin: const .only(bottom: 16),
            backgroundColor: colorScheme.surfaceContainerLow,
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
            onTap: onTap,
            child: content,
          )
        : AppFramedContainer(
            margin: const .only(bottom: 16),
            gap: .zero,
            onTap: onTap,
            child: content,
          );
  }
}

class _NotificationCardContent extends StatelessWidget {
  const _NotificationCardContent({
    required this.notification,
    required this.icon,
    required this.isRead,
    required this.locale,
    required this.colorScheme,
    required this.textTheme,
    required this.l10n,
  });

  final AppNotification notification;
  final IconData icon;
  final bool isRead;
  final String locale;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                ].separatedBy(8.w),
              ),
            ],
          ),
        ),
      ],
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return AppChipContainer(
      value: label,
      constraints: const BoxConstraints(maxWidth: 96),
      padding: const .symmetric(horizontal: 8, vertical: 4),
      textStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onPrimaryContainer,
        fontWeight: .bold,
      ),
    );
  }
}
