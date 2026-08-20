// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../domain/entities/extracurricular_attendance/extracurricular_attendance.dart';
import '../models/extracurricular_attendance/extracurricular_attendance_model.dart';

extension ExtracurricularAttendanceModelMapper
    on ExtracurricularAttendanceModel {
  ExtracurricularAttendance toEntity() => .new(
    id: id,
    sessionId: sessionId,
    namaKegiatan: namaKegiatan,
    unit: unit,
    tanggal: tanggal,
    materi: materi,
    namaGuru: namaGuru,
    status: status,
  );
}

extension ExtracurricularAttendanceDetailModelMapper
    on ExtracurricularAttendanceDetailModel {
  ExtracurricularAttendanceDetail toEntity() => .new(
    id: id,
    sessionId: sessionId,
    namaKegiatan: namaKegiatan,
    unit: unit,
    tanggal: tanggal,
    catatanKejadian: catatanKejadian,
    namaGuru: namaGuru,
    materi: materi,
    status: status,
  );
}
