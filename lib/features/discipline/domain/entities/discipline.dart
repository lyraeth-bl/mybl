// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'discipline.freezed.dart';

enum DisciplineType { merit, demerit }

@freezed
abstract class MeritEntity with _$MeritEntity {
  const factory MeritEntity({
    required int id,
    required int meritId,
    required String description,
    required int point,
    required DateTime date,
    required String nip,
    required String nis,
    required String schoolSession,
    required String semester,
    required String teacherName,
    required String unit,
  }) = _MeritEntity;
}

@freezed
abstract class DemeritEntity with _$DemeritEntity {
  const factory DemeritEntity({
    required int id,
    required int demeritId,
    required String description,
    required int point,
    required DateTime date,
    required String nip,
    required String nis,
    required String schoolSession,
    required String semester,
    required String teacherName,
    required String unit,
  }) = _DemeritEntity;
}
