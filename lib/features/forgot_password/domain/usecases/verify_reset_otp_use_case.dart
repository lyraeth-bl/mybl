// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../repositories/forgot_password_repository.dart';

class VerifyResetOtpUseCase {
  VerifyResetOtpUseCase(this._forgotPasswordRepository);

  final ForgotPasswordRepository _forgotPasswordRepository;

  Future<Result<String>> call({required String nis, required String otpCode}) =>
      _forgotPasswordRepository.verifyResetOtp(nis: nis, otpCode: otpCode);
}
