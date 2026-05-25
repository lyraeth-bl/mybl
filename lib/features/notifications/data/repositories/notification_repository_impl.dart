// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/internal/src/types.dart';
import '../../domain/entities/app_notification/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_data_source.dart';
import '../models/app_notification_model/app_notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._localDataSource);

  final NotificationLocalDataSource _localDataSource;

  @override
  Future<Result<List<AppNotification>>> readNotifications() async {
    final notifications = _localDataSource.readNotifications()
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

    return right(
      notifications
          .map((notification) => notification.toEntity())
          .toList(growable: false),
    );
  }

  @override
  Future<Result<Unit>> markAsRead(int id) async {
    final result = await _localDataSource.markAsRead(id);

    return right(result);
  }
}
