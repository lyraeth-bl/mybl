// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_token.freezed.dart';

@freezed
abstract class DeviceToken with _$DeviceToken {
  const factory DeviceToken({
    required int id,
    required String nis,
    required String token,
    required String platform,
    required String appVersion,
    DateTime? lastActiveAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _DeviceToken;
}
