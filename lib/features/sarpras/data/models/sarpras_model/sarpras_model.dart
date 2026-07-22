// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/sarpras/sarpras.dart';
import '../../../domain/entities/sarpras_metadata/sarpras_metadata.dart';
import '../../../domain/entities/sarpras_summary/sarpras_summary.dart';

part 'sarpras_model.freezed.dart';
part 'sarpras_model.g.dart';

@freezed
abstract class SarprasModel with _$SarprasModel {
  const factory SarprasModel({
    required int id,
    required String unit,
    @JsonKey(name: 'NIS') required String nis,
    @JsonKey(name: 'tanggal_kegiatan') required DateTime tanggalKegiatan,
    @JsonKey(name: 'nama_kegiatan') required String namaKegiatan,
    @JsonKey(name: 'jumlah_siswa_kelas')
    required String jumlahSiswaDalamKegiatan,
    @JsonKey(name: 'NIP_guru_pembimbing') required String nipGuruPembimbing,
    @JsonKey(name: 'waktu_kegiatan') required String waktuKegiatan,
    required String status,
    String? keterangan,
    @JsonKey(name: 'resolved_by_akses') String? aksesResolver,
    @JsonKey(name: 'resolved_by_nip') String? nipResolver,
    @JsonKey(name: 'resolved_by_nama') String? nameResolver,
    @JsonKey(name: 'alasan_tolak') String? alasanTolak,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SarprasModel;

  factory SarprasModel.fromJson(Map<String, dynamic> json) =>
      _$SarprasModelFromJson(json);
}

extension SarprasModelMapper on SarprasModel {
  Sarpras toEntity() => Sarpras(
    id: id,
    unit: unit,
    nis: nis,
    tanggalKegiatan: tanggalKegiatan,
    namaKegiatan: namaKegiatan,
    jumlahSiswaDalamKegiatan: jumlahSiswaDalamKegiatan,
    nipGuruPembimbing: nipGuruPembimbing,
    waktuKegiatan: waktuKegiatan,
    status: status,
    metadata: SarprasMetadata(
      keterangan: keterangan,
      aksesResolver: aksesResolver,
      nipResolver: nipResolver,
      nameResolver: nameResolver,
      alasanTolak: alasanTolak,
      resolvedAt: resolvedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
  );
}

@freezed
abstract class SarprasSummaryModel with _$SarprasSummaryModel {
  const factory SarprasSummaryModel({
    @JsonKey(name: 'Menunggu') @Default(0) int waiting,
    @JsonKey(name: 'Disetujui') @Default(0) int accepted,
    @JsonKey(name: 'Ditolak') @Default(0) int rejected,
  }) = _SarprasSummaryModel;

  factory SarprasSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$SarprasSummaryModelFromJson(json);
}

extension SarprasSummaryModelMapper on SarprasSummaryModel {
  SarprasSummary toEntity() =>
      SarprasSummary(waiting: waiting, accepted: accepted, rejected: rejected);
}
