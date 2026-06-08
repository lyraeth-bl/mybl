// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_notification/app_notification.dart';
import '../bloc/notification_bloc.dart';

class NotificationGroup {
  const NotificationGroup({required this.title, required this.items});

  final String title;
  final List<AppNotification> items;
}

List<NotificationGroup> groupNotifications(
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
      .map((entry) => NotificationGroup(title: entry.key, items: entry.value))
      .toList(growable: false);
}

String formatNotificationTime(DateTime date, String locale) {
  _ensureTimeagoLocaleMessages();

  return timeago.format(
    date,
    locale: _timeagoLocaleFor(locale),
    allowFromNow: true,
  );
}

IconData notificationIconForType(String type) {
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

bool notificationIsRead(AppNotification notification) {
  return notification.isRead.toLowerCase() == 'true' ||
      notification.isRead == '1' ||
      notification.isReadAt != null;
}

List<AppNotification> notificationsFromState(NotificationState state) {
  return state.maybeWhen(
    loading: (notifications) => notifications,
    success: (notifications) => notifications,
    orElse: () => const <AppNotification>[],
  );
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
