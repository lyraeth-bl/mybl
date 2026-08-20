// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/repositories/forgot_password_repository.dart';
import '../datasources/forgot_password_remote_data_source.dart';
import '../models/reset_password_request/reset_password_request.dart';
import '../models/send_otp_request/send_otp_request.dart';
import '../models/verify_otp_request/verify_otp_request.dart';

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  ForgotPasswordRepositoryImpl(this._remoteDataSource);

  final ForgotPasswordRemoteDataSource _remoteDataSource;

  @override
  Future<Result<Unit>> sendResetOtp({required String nis}) async {
    final request = SendOtpRequest(nis: nis);

    try {
      await _remoteDataSource.sendResetOtp(request);

      return right(unit);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<String>> verifyResetOtp({
    required String nis,
    required String otpCode,
  }) async {
    final request = VerifyOtpRequest(nis: nis, otpCode: otpCode);

    try {
      final response = await _remoteDataSource.verifyResetOtp(request);
      final resetToken = response.data?.resetToken ?? '';

      if (resetToken.isEmpty) {
        return left(Failure.serialization(errorMessage: response.message));
      }

      return right(resetToken);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<Unit>> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    final request = ResetPasswordRequest(
      resetToken: resetToken,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    try {
      await _remoteDataSource.resetPassword(request);

      return right(unit);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
