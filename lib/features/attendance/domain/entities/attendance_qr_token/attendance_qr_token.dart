// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_qr_token.freezed.dart';

@freezed
abstract class AttendanceQrToken with _$AttendanceQrToken {
  const factory AttendanceQrToken({
    required String token,
    required DateTime expiredAt,
    required int expiresIn,
  }) = _AttendanceQrToken;
}
