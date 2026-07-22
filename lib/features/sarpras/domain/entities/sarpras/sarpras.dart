// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../sarpras_metadata/sarpras_metadata.dart';

part 'sarpras.freezed.dart';

@freezed
abstract class Sarpras with _$Sarpras {
  const factory Sarpras({
    required int id,
    required String unit,
    required String nis,
    required DateTime tanggalKegiatan,
    required String namaKegiatan,
    required String jumlahSiswaDalamKegiatan,
    required String nipGuruPembimbing,
    required String waktuKegiatan,
    required String status,
    SarprasMetadata? metadata,
  }) = _Sarpras;
}
