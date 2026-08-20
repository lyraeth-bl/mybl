// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'extracurricular_attendance_model.freezed.dart';
part 'extracurricular_attendance_model.g.dart';

@freezed
abstract class ExtracurricularAttendanceModel
    with _$ExtracurricularAttendanceModel {
  const factory ExtracurricularAttendanceModel({
    required int id,
    @JsonKey(name: 'sesi_id') required int sessionId,
    @JsonKey(name: 'nama_kegiatan') required String namaKegiatan,
    required String unit,
    required DateTime tanggal,
    required String materi,
    @JsonKey(name: 'nama_guru') String? namaGuru,
    required String status,
  }) = _ExtracurricularAttendanceModel;

  factory ExtracurricularAttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$ExtracurricularAttendanceModelFromJson(json);
}

@freezed
abstract class ExtracurricularAttendanceDetailModel
    with _$ExtracurricularAttendanceDetailModel {
  const factory ExtracurricularAttendanceDetailModel({
    required int id,
    @JsonKey(name: 'sesi_id') required int sessionId,
    @JsonKey(name: 'nama_kegiatan') required String namaKegiatan,
    required String unit,
    required DateTime tanggal,
    required String materi,
    @JsonKey(name: 'catatan_kegiatan') String? catatanKejadian,
    @JsonKey(name: 'nama_guru') String? namaGuru,
    required String status,
  }) = _ExtracurricularAttendanceDetailModel;

  factory ExtracurricularAttendanceDetailModel.fromJson(
    Map<String, dynamic> json,
  ) => _$ExtracurricularAttendanceDetailModelFromJson(json);
}
