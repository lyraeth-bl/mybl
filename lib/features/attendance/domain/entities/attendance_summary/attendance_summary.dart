// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_summary.freezed.dart';

@freezed
abstract class AttendanceSummary with _$AttendanceSummary {
  const factory AttendanceSummary({
    @Default(0) int present,
    @Default(0) int late,
    @Default(0) int excused,
    @Default(0) int absent,
    @Default(0) int workingDaysElapsed,
  }) = _AttendanceSummary;

  const AttendanceSummary._();

  int get total => present + late + excused + absent;

  double get attendanceRate {
    if (workingDaysElapsed == 0) return 0.0;
    return (present + late) / workingDaysElapsed;
  }
}
