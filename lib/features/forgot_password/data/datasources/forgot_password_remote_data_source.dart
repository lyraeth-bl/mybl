// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/reset_password_request/reset_password_request.dart';
import '../models/send_otp_request/send_otp_request.dart';
import '../models/verify_otp_request/verify_otp_request.dart';
import '../models/verify_otp_response/verify_otp_response.dart';

abstract class ForgotPasswordRemoteDataSource {
  Future<Unit> sendResetOtp(SendOtpRequest request);

  Future<VerifyOtpResponse> verifyResetOtp(VerifyOtpRequest request);

  Future<Unit> resetPassword(ResetPasswordRequest request);
}

final class ForgotPasswordRemoteDataSourceImpl
    implements ForgotPasswordRemoteDataSource {
  ForgotPasswordRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<Unit> sendResetOtp(SendOtpRequest request) => _httpRequest
      .post(ApiEndpoints.sendForgotPasswordOtp, data: request.toJson())
      .then((_) => unit);

  @override
  Future<VerifyOtpResponse> verifyResetOtp(VerifyOtpRequest request) =>
      _httpRequest
          .post(ApiEndpoints.verifyForgotPasswordOtp, data: request.toJson())
          .then(VerifyOtpResponse.fromJson);

  @override
  Future<Unit> resetPassword(ResetPasswordRequest request) => _httpRequest
      .post(ApiEndpoints.resetForgotPassword, data: request.toJson())
      .then((_) => unit);
}
