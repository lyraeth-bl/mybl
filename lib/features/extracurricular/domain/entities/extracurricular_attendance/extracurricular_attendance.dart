// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'extracurricular_attendance.freezed.dart';

@freezed
abstract class ExtracurricularAttendance with _$ExtracurricularAttendance {
  const factory ExtracurricularAttendance({
    required int id,
    required int sessionId,
    required String namaKegiatan,
    required String unit,
    required DateTime tanggal,
    required String materi,
    String? namaGuru,
    required String status,
  }) = _ExtracurricularAttendance;
}

@freezed
abstract class ExtracurricularAttendanceDetail
    with _$ExtracurricularAttendanceDetail {
  const factory ExtracurricularAttendanceDetail({
    required int id,
    required int sessionId,
    required String namaKegiatan,
    required String unit,
    required DateTime tanggal,
    required String materi,
    String? catatanKejadian,
    String? namaGuru,
    required String status,
  }) = _ExtracurricularAttendanceDetail;
}
