// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/internal/src/types.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  MarkNotificationAsReadUseCase(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  Future<Result<Unit>> call(int id) => _notificationRepository.markAsRead(id);
}
