// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/device_token_request/device_token_request.dart';
import '../models/device_token_response/device_token_response.dart';

abstract class DeviceTokenRemoteDataSource {
  Future<DeviceTokenResponse> registerDeviceToken(DeviceTokenRequest data);

  Future<Unit> revokeDeviceToken({required String fcmToken});
}

class DeviceTokenRemoteDataSourceImpl implements DeviceTokenRemoteDataSource {
  DeviceTokenRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<DeviceTokenResponse> registerDeviceToken(
    DeviceTokenRequest data,
  ) async {
    final request = data.toJson();

    final response = await _httpRequest.post(
      ApiEndpoints.deviceTokens,
      data: request,
    );

    return DeviceTokenResponse.fromJson(response);
  }

  @override
  Future<Unit> revokeDeviceToken({required String fcmToken}) async {
    await _httpRequest.delete(
      ApiEndpoints.deviceTokens,
      data: {'token': fcmToken},
    );

    return unit;
  }
}
