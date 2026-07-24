// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/internal/src/extensions/extensions.dart';
import '../../../domain/entities/sarpras_params/sarpras_params.dart';

part 'sarpras_request.freezed.dart';
part 'sarpras_request.g.dart';

@freezed
abstract class SarprasRequest with _$SarprasRequest {
  const factory SarprasRequest({
    @JsonKey(name: 'tanggal_kegiatan') required DateTime tanggalKegiatan,
    @JsonKey(name: 'nama_kegiatan') required String namaKegiatan,
    @JsonKey(name: 'jumlah_siswa_kelas')
    required String jumlahSiswaDalamKegiatan,
    @JsonKey(name: 'NIP_guru_pembimbing') required String nipGuruPembimbing,
    @JsonKey(name: 'jam_mulai') required String jamMulaiKegiatan,
    @JsonKey(name: 'jam_selesai') required String jamSelesaiKegiatan,
    String? keterangan,
  }) = _SarprasRequest;

  factory SarprasRequest.fromJson(Map<String, dynamic> json) =>
      _$SarprasRequestFromJson(json);
}

extension SarprasParamsMapper on SarprasParams {
  SarprasRequest toRequest() => SarprasRequest(
    tanggalKegiatan: tanggalKegiatan,
    namaKegiatan: namaKegiatan,
    jumlahSiswaDalamKegiatan: jumlahSiswaDalamKegiatan,
    nipGuruPembimbing: nipGuruPembimbing,
    jamMulaiKegiatan: jamMulaiKegiatan.toHourMinuteFormat(),
    jamSelesaiKegiatan: jamSelesaiKegiatan.toHourMinuteFormat(),
    keterangan: keterangan,
  );
}
