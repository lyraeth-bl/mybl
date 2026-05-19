// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/discipline.dart';

part 'discipline_model.freezed.dart';
part 'discipline_model.g.dart';

@freezed
abstract class MeritModel with _$MeritModel {
  const factory MeritModel({
    required int id,
    @JsonKey(name: "id_merit") required int meritId,
    @JsonKey(name: "Penghargaan") required String description,
    @JsonKey(name: "Point") required int point,
    @JsonKey(name: "Tanggal") required DateTime date,
    @JsonKey(name: "NIP") required String nip,
    @JsonKey(name: "NIS") required String nis,
    @JsonKey(name: "Tajaran") required String schoolSession,
    @JsonKey(name: "Semester") required String semester,
    @JsonKey(name: "nama_guru") required String teacherName,
    required String unit,
  }) = _MeritModel;

  factory MeritModel.fromJson(Map<String, dynamic> json) =>
      _$MeritModelFromJson(json);
}

@freezed
abstract class DemeritModel with _$DemeritModel {
  const factory DemeritModel({
    required int id,
    @JsonKey(name: "id_demerit") required int demeritId,
    @JsonKey(name: "Pelanggaran") required String description,
    @JsonKey(name: "Point") required int point,
    @JsonKey(name: "Tanggal") required DateTime date,
    @JsonKey(name: "NIP") required String nip,
    @JsonKey(name: "NIS") required String nis,
    @JsonKey(name: "Tajaran") required String schoolSession,
    @JsonKey(name: "Semester") required String semester,
    @JsonKey(name: "nama_guru") required String teacherName,
    required String unit,
  }) = _DemeritModel;

  factory DemeritModel.fromJson(Map<String, dynamic> json) =>
      _$DemeritModelFromJson(json);
}

extension MeritModelMapper on MeritModel {
  MeritEntity toEntity() => MeritEntity(
    id: id,
    meritId: meritId,
    description: description,
    point: point,
    date: date,
    nip: nip,
    nis: nis,
    schoolSession: schoolSession,
    semester: semester,
    teacherName: teacherName,
    unit: unit,
  );
}

extension DemeritModelMapper on DemeritModel {
  DemeritEntity toEntity() => DemeritEntity(
    id: id,
    demeritId: demeritId,
    description: description,
    point: point,
    date: date,
    nip: nip,
    nis: nis,
    schoolSession: schoolSession,
    semester: semester,
    teacherName: teacherName,
    unit: unit,
  );
}
