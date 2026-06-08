// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/app_notification/app_notification.dart';

part 'app_notification_model.freezed.dart';
part 'app_notification_model.g.dart';

@freezed
abstract class AppNotificationModel with _$AppNotificationModel {
  const factory AppNotificationModel({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'title') required String title,
    @JsonKey(name: 'body') required String body,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'data_payload') required Object dataPayload,
    @JsonKey(name: 'target_type') required String targetType,
    @JsonKey(name: 'target_value') required String targetValue,
    @JsonKey(name: 'recipient_nis') required String recipientNis,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'fcm_message_id') String? fcmMessageId,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'sent_at') required DateTime sentAt,
    @JsonKey(name: 'is_read') required String isRead,
    @JsonKey(name: 'is_read_at') DateTime? isReadAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _AppNotificationModel;

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationModelFromJson(json);

  factory AppNotificationModel.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final now = DateTime.now();

    return AppNotificationModel(
      id: _parseInt(data['id']) ?? message.messageId.hashCode,
      type: _stringValue(data['type'], fallback: 'notification'),
      title: _stringValue(data['title'], fallback: message.notification?.title),
      body: _stringValue(data['body'], fallback: message.notification?.body),
      imageUrl: _remoteImageUrl(message),
      dataPayload: _parsePayload(data['data_payload'], fallback: data),
      targetType: _stringValue(data['target_type']),
      targetValue: _stringValue(data['target_value']),
      recipientNis: _stringValue(data['recipient_nis']),
      status: _stringValue(data['status'], fallback: 'received'),
      fcmMessageId:
          _nullableString(data['fcm_message_id']) ?? message.messageId,
      errorMessage: _nullableString(data['error_message']),
      sentAt: _parseDate(data['sent_at']) ?? message.sentTime ?? now,
      isRead: _stringValue(data['is_read'], fallback: 'false'),
      isReadAt: _parseDate(data['is_read_at']),
      createdAt: _parseDate(data['created_at']) ?? now,
      updatedAt: _parseDate(data['updated_at']),
    );
  }
}

extension AppNotificationModelMapper on AppNotificationModel {
  AppNotification toEntity() => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    imageUrl: imageUrl,
    dataPayload: dataPayload,
    targetType: targetType,
    targetValue: targetValue,
    recipientNis: recipientNis,
    status: status,
    fcmMessageId: fcmMessageId,
    errorMessage: errorMessage,
    sentAt: sentAt,
    isRead: isRead,
    isReadAt: isReadAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

String _stringValue(Object? value, {String? fallback}) {
  final parsed = _nullableString(value);
  if (parsed != null) return parsed;

  return fallback ?? '';
}

String? _nullableString(Object? value) {
  if (value == null) return null;

  final stringValue = value.toString();
  if (stringValue.isEmpty) return null;

  return stringValue;
}

String? _remoteImageUrl(RemoteMessage message) {
  final data = message.data;

  return _nullableString(data['image_url']) ??
      _nullableString(data['imageUrl']) ??
      _nullableString(message.notification?.android?.imageUrl) ??
      _nullableString(message.notification?.apple?.imageUrl);
}

int? _parseInt(Object? value) {
  if (value is int) return value;

  return int.tryParse(value?.toString() ?? '');
}

DateTime? _parseDate(Object? value) {
  if (value is DateTime) return value;

  return DateTime.tryParse(value?.toString() ?? '');
}

Object _parsePayload(Object? value, {required Map<String, dynamic> fallback}) {
  if (value == null) return Map<String, dynamic>.from(fallback);
  if (value is Map<String, dynamic>) return value;

  try {
    final decoded = jsonDecode(value.toString());
    if (decoded is Object) return decoded;
  } on FormatException {
    return value.toString();
  }

  return value.toString();
}
