// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../extracurricular_attendance/extracurricular_attendance_model.dart';

part 'extracurricular_attendance_response.freezed.dart';
part 'extracurricular_attendance_response.g.dart';

@freezed
abstract class ExtracurricularAttendanceResponse
    with _$ExtracurricularAttendanceResponse {
  const factory ExtracurricularAttendanceResponse({
    required bool error,
    required String message,
    @JsonKey(name: 'data')
    @Default(<ExtracurricularAttendanceModel>[])
    List<ExtracurricularAttendanceModel> extracurricularAttendances,
  }) = _ExtracurricularAttendanceResponse;

  factory ExtracurricularAttendanceResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$ExtracurricularAttendanceResponseFromJson(json);
}

@freezed
abstract class ExtracurricularAttendanceDetailResponse
    with _$ExtracurricularAttendanceDetailResponse {
  const factory ExtracurricularAttendanceDetailResponse({
    required bool error,
    required String message,
    @JsonKey(name: 'data')
    required ExtracurricularAttendanceDetailModel
    detailExtracurricularAttendance,
  }) = _ExtracurricularAttendanceDetailResponse;

  factory ExtracurricularAttendanceDetailResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$ExtracurricularAttendanceDetailResponseFromJson(json);
}
