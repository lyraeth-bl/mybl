// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/attendance_qr_token/attendance_qr_token.dart';

part 'attendance_qr_token_model.freezed.dart';
part 'attendance_qr_token_model.g.dart';

@freezed
abstract class AttendanceQrTokenModel with _$AttendanceQrTokenModel {
  const factory AttendanceQrTokenModel({
    required String token,
    @JsonKey(name: 'expired_at') required DateTime expiredAt,
    @JsonKey(name: 'expires_in') required int expiresIn,
  }) = _AttendanceQrTokenModel;

  factory AttendanceQrTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceQrTokenModelFromJson(json);
}

extension AttendanceQrTokenModelMapper on AttendanceQrTokenModel {
  AttendanceQrToken toEntity() => AttendanceQrToken(
    token: token,
    expiredAt: expiredAt,
    expiresIn: expiresIn,
  );
}
