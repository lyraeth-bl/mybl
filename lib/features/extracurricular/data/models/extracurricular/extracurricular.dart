// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/extracurricular.dart';

part 'extracurricular.freezed.dart';
part 'extracurricular.g.dart';

@freezed
abstract class ExtracurricularModel with _$ExtracurricularModel {
  const factory ExtracurricularModel({
    required int id,
    @JsonKey(name: "NIS") required String nis,
    @JsonKey(name: "Kelas") required String kelas,
    @JsonKey(name: "NomorKelas") required String nomorKelas,
    @JsonKey(name: "NamaKegiatan") required String namaKegiatan,
    @JsonKey(name: "Tajaran") required String tajaran,
    @JsonKey(name: "Semester") required String semester,
    @JsonKey(name: "Nilai") required String nilai,
  }) = _ExtracurricularModel;

  factory ExtracurricularModel.fromJson(Map<String, dynamic> json) =>
      _$ExtracurricularModelFromJson(json);
}

extension ExtracurricularModelMapper on ExtracurricularModel {
  ExtracurricularEntity toEntity() => ExtracurricularEntity(
    id: id,
    nis: nis,
    kelas: kelas,
    nomorKelas: nomorKelas,
    namaKegiatan: namaKegiatan,
    tajaran: tajaran,
    semester: semester,
    nilai: nilai,
  );
}
