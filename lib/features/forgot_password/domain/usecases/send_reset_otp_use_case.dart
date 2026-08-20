// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/internal/src/types.dart';
import '../repositories/forgot_password_repository.dart';

class SendResetOtpUseCase {
  SendResetOtpUseCase(this._forgotPasswordRepository);

  final ForgotPasswordRepository _forgotPasswordRepository;

  Future<Result<Unit>> call({required String nis}) =>
      _forgotPasswordRepository.sendResetOtp(nis: nis);
}
