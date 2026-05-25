// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../device_token_model/device_token_model.dart';

part 'device_token_response.freezed.dart';
part 'device_token_response.g.dart';

@freezed
abstract class DeviceTokenResponse with _$DeviceTokenResponse {
  const factory DeviceTokenResponse({
    @JsonKey(name: 'error') required bool error,
    @JsonKey(name: 'message') required String message,
    @JsonKey(name: 'data') required DeviceTokenModel deviceToken,
  }) = _DeviceTokenResponse;

  factory DeviceTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenResponseFromJson(json);
}
