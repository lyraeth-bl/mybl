// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_notification/app_notification.dart';
import '../bloc/notification_bloc.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationBloc>(
      create: (context) => di<NotificationBloc>(),
      child: const _NotificationScreenView(),
    );
  }
}

class _NotificationScreenView extends StatefulWidget {
  const _NotificationScreenView();

  @override
  State<_NotificationScreenView> createState() =>
      _NotificationScreenViewState();
}

class _NotificationScreenViewState extends State<_NotificationScreenView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<NotificationBloc>().add(
        const NotificationEvent.fetchNotificationsRequested(),
      ),
    );
  }

  Future<void> _refresh() {
    return blocRefresh<NotificationBloc, NotificationEvent, NotificationState>(
      context: context,
      event: const NotificationEvent.fetchNotificationsRequested(),
      isDone: (state) => state.maybeWhen(
        success: (_) => true,
        failure: (_) => true,
        orElse: () => false,
      ),
    );
  }

  void _markAsRead(AppNotification notification) {
    if (_isRead(notification)) return;

    context.read<NotificationBloc>().add(
      NotificationEvent.notificationReadRequested(notification: notification),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<NotificationBloc, NotificationState>(
      listenWhen: (previous, current) =>
          current.maybeWhen(failure: (_) => true, orElse: () => false),
      listener: (context, state) {
        final failure = state.whenOrNull(failure: (failure) => failure);
        if (failure == null) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.localizedMessage(l10n))));
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        body: RefreshWrapper(
          onRefresh: _refresh,
          child: BlocBuilder<NotificationBloc, NotificationState>(
            buildWhen: (previous, current) {
              final previousData = _notificationsFromState(previous);
              final currentData = _notificationsFromState(current);

              return previousData != currentData ||
                  previous.runtimeType != current.runtimeType;
            },
            builder: (context, state) {
              final notifications = _notificationsFromState(state);
              final groups = _groupNotifications(context, notifications);

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const _NotificationHeader(),
                  if (groups.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _NotificationEmptyState(),
                    )
                  else ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    for (final group in groups)
                      _NotificationSliverGroup(
                        group: group,
                        onNotificationTap: _markAsRead,
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader();

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

class _NotificationSliverGroup extends StatelessWidget {
  const _NotificationSliverGroup({
    required this.group,
    required this.onNotificationTap,
  });

  final _NotificationGroup group;
  final ValueChanged<AppNotification> onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _NotificationHeaderDelegate(title: group.title),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 16),
          sliver: SliverList.separated(
            itemCount: group.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notification = group.items[index];

              return _NotificationCard(
                notification: notification,
                onTap: () => onNotificationTap(notification),
              );
            },
          ),
        ),
      ],
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
    final isRead = _isRead(notification);
    final icon = _iconForType(notification.type);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: isRead ? colorScheme.surface : colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NotificationLeadingIcon(
                  icon: icon,
                  imageUrl: notification.imageUrl,
                  isRead: isRead,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isRead) ...[
                            const SizedBox(width: 8),
                            _UnreadBadge(label: l10n.unread),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatNotificationTime(
                                notification.sentAt,
                                locale,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
          ),
        ),
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
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(icon, color: foregroundColor, size: 24)
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(icon, color: foregroundColor, size: 24),
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

    return Container(
      constraints: const BoxConstraints(maxWidth: 96),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NotificationHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _NotificationHeaderDelegate({required this.title});

  final String title;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = (shrinkOffset / maxExtent).clamp(0.0, 1.0);

    return ColoredBox(
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Transform.translate(
            offset: Offset((1 - progress) * 4, 0),
            child: Opacity(
              opacity: (progress * 0.5 + 0.5).clamp(0.0, 1.0),
              child: Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 44;

  @override
  double get minExtent => 44;

  @override
  bool shouldRebuild(covariant _NotificationHeaderDelegate oldDelegate) {
    return oldDelegate.title != title;
  }
}

class _NotificationEmptyState extends StatelessWidget {
  const _NotificationEmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              color: colorScheme.onPrimaryContainer,
              size: 36,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.noNotifications,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noNotificationsDesc,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationGroup {
  const _NotificationGroup({required this.title, required this.items});

  final String title;
  final List<AppNotification> items;
}

List<_NotificationGroup> _groupNotifications(
  BuildContext context,
  List<AppNotification> notifications,
) {
  final l10n = AppLocalizations.of(context)!;
  final locale = Localizations.localeOf(context).toString();
  final groups = <String, List<AppNotification>>{};

  for (final notification in notifications) {
    final title = _formatGroupTitle(notification.sentAt, l10n, locale);
    groups.putIfAbsent(title, () => <AppNotification>[]).add(notification);
  }

  return groups.entries
      .map((entry) => _NotificationGroup(title: entry.key, items: entry.value))
      .toList(growable: false);
}

String _formatGroupTitle(DateTime date, AppLocalizations l10n, String locale) {
  final now = DateTime.now();
  final currentDay = DateTime(now.year, now.month, now.day);
  final notificationDay = DateTime(date.year, date.month, date.day);
  final difference = currentDay.difference(notificationDay).inDays;

  if (difference == 0) return l10n.today;
  if (difference == 1) return l10n.yesterday;

  return DateFormat('EEEE, d MMMM yyyy', locale).format(date);
}

String _formatNotificationTime(DateTime date, String locale) {
  _ensureTimeagoLocaleMessages();

  return timeago.format(
    date,
    locale: _timeagoLocaleFor(locale),
    allowFromNow: true,
  );
}

bool _timeagoLocaleMessagesRegistered = false;

void _ensureTimeagoLocaleMessages() {
  if (_timeagoLocaleMessagesRegistered) return;

  timeago.setLocaleMessages('id', timeago.IdMessages());
  timeago.setLocaleMessages('id_ID', timeago.IdMessages());
  timeago.setLocaleMessages('en_US', timeago.EnMessages());
  _timeagoLocaleMessagesRegistered = true;
}

String _timeagoLocaleFor(String locale) {
  if (locale.startsWith('id')) return locale == 'id' ? 'id' : 'id_ID';
  if (locale.startsWith('en')) return locale == 'en' ? 'en' : 'en_US';

  return 'en';
}

IconData _iconForType(String type) {
  final normalizedType = type.toLowerCase();

  if (normalizedType.contains('attendance')) {
    return Icons.fact_check_outlined;
  }
  if (normalizedType.contains('calendar') || normalizedType.contains('event')) {
    return Icons.event_note_outlined;
  }
  if (normalizedType.contains('academic') || normalizedType.contains('score')) {
    return Icons.school_outlined;
  }
  if (normalizedType.contains('discipline') ||
      normalizedType.contains('merit') ||
      normalizedType.contains('demerit')) {
    return Icons.verified_outlined;
  }

  return Icons.notifications_outlined;
}

bool _isRead(AppNotification notification) {
  return notification.isRead.toLowerCase() == 'true' ||
      notification.isRead == '1' ||
      notification.isReadAt != null;
}

List<AppNotification> _notificationsFromState(NotificationState state) {
  return state.maybeWhen(
    loading: (notifications) => notifications,
    success: (notifications) => notifications,
    orElse: () => const <AppNotification>[],
  );
}
