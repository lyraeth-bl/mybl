// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_entity.freezed.dart';

@freezed
abstract class AttendanceEntity with _$AttendanceEntity {
  const factory AttendanceEntity({
    required int id,
    required String nis,
    required String tajaran,
    required String semester,
    required DateTime tanggal,
    DateTime? jamCheckIn,
    DateTime? jamCheckOut,
    required String status,
    String? alasan,
    required String unit,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AttendanceEntity;
}
