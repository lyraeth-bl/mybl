// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../attendance_model/attendance_model.dart';

part 'monthly_attendance_response.freezed.dart';
part 'monthly_attendance_response.g.dart';

@freezed
abstract class MonthlyAttendanceResponse with _$MonthlyAttendanceResponse {
  const factory MonthlyAttendanceResponse({
    required bool error,
    required String message,
    @JsonKey(name: 'data') required List<AttendanceModel> monthlyAttendance,
  }) = _MonthlyAttendanceResponse;

  factory MonthlyAttendanceResponse.fromJson(Map<String, dynamic> json) =>
      _$MonthlyAttendanceResponseFromJson(json);
}
