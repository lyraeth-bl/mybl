// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../attendance_model/attendance_model.dart';

part 'daily_attendance_response.freezed.dart';
part 'daily_attendance_response.g.dart';

@freezed
abstract class DailyAttendanceResponse with _$DailyAttendanceResponse {
  const factory DailyAttendanceResponse({
    required bool error,
    required String message,
    @JsonKey(name: 'data') AttendanceModel? dailyAttendance,
  }) = _DailyAttendanceResponse;

  factory DailyAttendanceResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyAttendanceResponseFromJson(json);
}
