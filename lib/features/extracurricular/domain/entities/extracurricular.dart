// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'extracurricular.freezed.dart';

@freezed
abstract class ExtracurricularEntity with _$ExtracurricularEntity {
  const factory ExtracurricularEntity({
    required int id,
    required String nis,
    required String kelas,
    required String nomorKelas,
    required String namaKegiatan,
    required String tajaran,
    required String semester,
    required String nilai,
  }) = _ExtracurricularEntity;
}
