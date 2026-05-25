// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/device_token.dart';

part 'device_token_model.freezed.dart';
part 'device_token_model.g.dart';

@freezed
abstract class DeviceTokenModel with _$DeviceTokenModel {
  const factory DeviceTokenModel({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'NIS') required String nis,
    @JsonKey(name: 'token') required String token,
    @JsonKey(name: 'platform') required String platform,
    @JsonKey(name: 'app_version') required String appVersion,
    @JsonKey(name: 'last_active_at') DateTime? lastActiveAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _DeviceTokenModel;

  factory DeviceTokenModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenModelFromJson(json);
}

extension DeviceTokenModelMapper on DeviceTokenModel {
  DeviceToken toEntity() => DeviceToken(
    id: id,
    nis: nis,
    token: token,
    platform: platform,
    appVersion: appVersion,
    lastActiveAt: lastActiveAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
