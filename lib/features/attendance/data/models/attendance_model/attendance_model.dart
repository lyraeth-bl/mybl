// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/attendance_entity/attendance_entity.dart';

part 'attendance_model.freezed.dart';
part 'attendance_model.g.dart';

@freezed
abstract class AttendanceModel with _$AttendanceModel {
  const factory AttendanceModel({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "nis") required String nis,
    @JsonKey(name: "tajaran") required String tajaran,
    @JsonKey(name: "semester") required String semester,
    @JsonKey(name: "tanggal") required DateTime tanggal,
    @JsonKey(name: "checkIn") DateTime? jamCheckIn,
    @JsonKey(name: "checkOut") DateTime? jamCheckOut,
    @JsonKey(name: "status") required String status,
    @JsonKey(name: "alasan") String? alasan,
    @JsonKey(name: "unit") required String unit,
    @JsonKey(name: "created_at") required DateTime createdAt,
    @JsonKey(name: "updated_at") required DateTime updatedAt,
  }) = _AttendanceModel;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);
}

extension AttendanceModelMapper on AttendanceModel {
  AttendanceEntity toEntity() => AttendanceEntity(
    id: id,
    nis: nis,
    tajaran: tajaran,
    semester: semester,
    tanggal: tanggal,
    jamCheckIn: jamCheckIn,
    jamCheckOut: jamCheckOut,
    status: status,
    alasan: alasan,
    unit: unit,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
