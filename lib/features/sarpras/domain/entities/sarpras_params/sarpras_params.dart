// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sarpras_params.freezed.dart';

@freezed
abstract class SarprasParams with _$SarprasParams {
  const factory SarprasParams({
    required DateTime tanggalKegiatan,
    required String namaKegiatan,
    required String jumlahSiswaDalamKegiatan,
    required String nipGuruPembimbing,
    required DateTime jamMulaiKegiatan,
    required DateTime jamSelesaiKegiatan,
    String? keterangan,
  }) = _SarprasParams;
}
