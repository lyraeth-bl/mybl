// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/repositories/repository.dart';
import '../datasources/device_token_metadata_provider.dart';
import '../datasources/remote.dart';
import '../models/device_token_request/device_token_request.dart';

class DeviceTokenRepositoryImpl implements DeviceTokenRepository {
  DeviceTokenRepositoryImpl(this._remoteDataSource, this._metadataProvider);

  final DeviceTokenRemoteDataSource _remoteDataSource;
  final DeviceTokenMetadataProvider _metadataProvider;

  @override
  Future<Result<Unit>> registerDeviceToken({required String fcmToken}) async {
    try {
      final request = DeviceTokenRequest(
        token: fcmToken,
        platform: _metadataProvider.platform,
        appVersion: await _metadataProvider.readAppVersion(),
      );

      await _remoteDataSource.registerDeviceToken(request);

      return right(unit);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<Unit>> revokeDeviceToken({required String fcmToken}) async {
    try {
      await _remoteDataSource.revokeDeviceToken(fcmToken: fcmToken);

      return right(unit);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
