// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../attendance_qr_token_model/attendance_qr_token_model.dart';

part 'attendance_qr_token_response.freezed.dart';
part 'attendance_qr_token_response.g.dart';

@freezed
abstract class AttendanceQrTokenResponse with _$AttendanceQrTokenResponse {
  const factory AttendanceQrTokenResponse({
    required bool status,
    required String message,
    @JsonKey(name: 'data') required AttendanceQrTokenModel qrToken,
  }) = _AttendanceQrTokenResponse;

  factory AttendanceQrTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$AttendanceQrTokenResponseFromJson(json);
}
