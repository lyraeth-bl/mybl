// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../sarpras_metadata/sarpras_metadata.dart';

part 'sarpras.freezed.dart';

@freezed
abstract class Sarpras with _$Sarpras {
  const Sarpras._();

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

  /// Whether the request can still be edited or withdrawn.
  ///
  /// The backend rejects changes to processed requests with a 422, so this
  /// mirrors that rule client-side.
  bool get isCancelable => status == 'Menunggu';
}
