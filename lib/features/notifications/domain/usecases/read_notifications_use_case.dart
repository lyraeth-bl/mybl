// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/app_notification/app_notification.dart';
import '../repositories/notification_repository.dart';

class ReadNotificationsUseCase {
  ReadNotificationsUseCase(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  Future<Result<List<AppNotification>>> call() =>
      _notificationRepository.readNotifications();
}
