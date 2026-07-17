// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/api_client/api_client.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/device_token_request/device_token_request.dart';
import '../models/device_token_response/device_token_response.dart';

abstract class DeviceTokenRemoteDataSource {
  Future<DeviceTokenResponse> registerDeviceToken(
    DeviceTokenRequest data,
    UserRole role,
  );

  Future<Unit> revokeDeviceToken({
    required String fcmToken,
    required UserRole role,
  });
}

class DeviceTokenRemoteDataSourceImpl implements DeviceTokenRemoteDataSource {
  DeviceTokenRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<DeviceTokenResponse> registerDeviceToken(
    DeviceTokenRequest data,
    UserRole role,
  ) async {
    final endpoint = role == UserRole.parent
        ? ApiEndpoints.parentDeviceTokens
        : ApiEndpoints.deviceTokens;

    final response = await _httpRequest.post(endpoint, data: data.toJson());

    return DeviceTokenResponse.fromJson(response);
  }

  @override
  Future<Unit> revokeDeviceToken({
    required String fcmToken,
    required UserRole role,
  }) async {
    final endpoint = role == UserRole.parent
        ? ApiEndpoints.parentDeviceTokens
        : ApiEndpoints.deviceTokens;

    await _httpRequest.delete(endpoint, data: {'token': fcmToken});

    return unit;
  }
}
