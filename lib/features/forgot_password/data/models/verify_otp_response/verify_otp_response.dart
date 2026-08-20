// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_otp_response.freezed.dart';
part 'verify_otp_response.g.dart';

@freezed
abstract class VerifyOtpResponse with _$VerifyOtpResponse {
  const factory VerifyOtpResponse({
    @JsonKey(name: 'error') required bool error,
    @JsonKey(name: 'message') String? message,
    @JsonKey(name: 'data') VerifyOtpData? data,
  }) = _VerifyOtpResponse;

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpResponseFromJson(json);
}

@freezed
abstract class VerifyOtpData with _$VerifyOtpData {
  const factory VerifyOtpData({
    @JsonKey(name: 'reset_token') @Default('') String resetToken,
  }) = _VerifyOtpData;

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpDataFromJson(json);
}
