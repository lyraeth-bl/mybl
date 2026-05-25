// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/internal/src/types.dart';
import '../repositories/repository.dart';

class RegisterDeviceTokenUseCase {
  RegisterDeviceTokenUseCase(this._deviceTokenRepository);

  final DeviceTokenRepository _deviceTokenRepository;

  Future<Result<Unit>> call({required String fcmToken}) =>
      _deviceTokenRepository.registerDeviceToken(fcmToken: fcmToken);
}
