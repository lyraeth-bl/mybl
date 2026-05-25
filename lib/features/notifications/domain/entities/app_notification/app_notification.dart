// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';

@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required int id,
    required String type,
    required String title,
    required String body,
    String? imageUrl,
    required Object dataPayload,
    required String targetType,
    required String targetValue,
    required String recipientNis,
    required String status,
    String? fcmMessageId,
    String? errorMessage,
    required DateTime sentAt,
    required String isRead,
    DateTime? isReadAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _AppNotification;
}
