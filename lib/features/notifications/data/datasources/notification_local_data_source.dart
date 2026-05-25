// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';
import '../models/app_notification_model/app_notification_model.dart';

abstract class NotificationLocalDataSource
    implements NotificationLocalManager<AppNotificationModel> {}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  NotificationLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  @override
  List<AppNotificationModel> readNotifications() {
    final rawListData = _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .get(HiveStorageNames.userNotificationsKey);

    if (rawListData == null) return [];

    return (rawListData as List<dynamic>)
        .map((m) => AppNotificationModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  Future<Unit> saveNotification(AppNotificationModel data) async {
    final notifications = readNotifications();
    final duplicateIndex = notifications.indexWhere(
      (notification) =>
          notification.id == data.id ||
          (data.fcmMessageId != null &&
              notification.fcmMessageId == data.fcmMessageId),
    );

    if (duplicateIndex >= 0) {
      notifications[duplicateIndex] = data;
    } else {
      notifications.insert(0, data);
    }

    await _saveAll(notifications);

    return unit;
  }

  @override
  Future<Unit> markAsRead(int id) async {
    final notifications = readNotifications();
    final now = DateTime.now();
    final updatedNotifications = notifications
        .map(
          (notification) => notification.id == id
              ? notification.copyWith(isRead: 'true', isReadAt: now)
              : notification,
        )
        .toList();

    await _saveAll(updatedNotifications);

    return unit;
  }

  @override
  Future<Unit> clearNotifications() async {
    await _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .delete(HiveStorageNames.userNotificationsKey);

    return unit;
  }

  Future<void> _saveAll(List<AppNotificationModel> notifications) async {
    await _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .put(
          HiveStorageNames.userNotificationsKey,
          notifications.map((notification) => notification.toJson()).toList(),
        );
  }
}
