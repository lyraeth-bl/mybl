// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/sarpras/data/models/sarpras_detail_response/sarpras_detail_response.dart';
import 'package:my_bl/features/sarpras/data/models/sarpras_model/sarpras_model.dart';
import 'package:my_bl/features/sarpras/data/models/sarpras_request/sarpras_request.dart';
import 'package:my_bl/features/sarpras/data/models/sarpras_response/sarpras_response.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras_params/sarpras_params.dart';

const Map<String, dynamic> _item = {
  'id': 12,
  'unit': 'SMA',
  'NIS': '2023001',
  'tanggal_kegiatan': '2026-07-20T00:00:00.000Z',
  'nama_kegiatan': 'Latihan Paskibra',
  'jumlah_siswa_kelas': '30',
  'NIP_guru_pembimbing': '198701012010011001',
  'waktu_kegiatan': '07:00 - 09:00',
  'keterangan': null,
  'status': 'Menunggu',
};

void main() {
  group('SarprasModel.fromJson', () {
    test('membaca NIP guru pembimbing sesuai key API', () {
      final model = SarprasModel.fromJson(_item);

      expect(model.nipGuruPembimbing, '198701012010011001');
      expect(model.jumlahSiswaDalamKegiatan, '30');
      expect(model.waktuKegiatan, '07:00 - 09:00');
    });

    test('memetakan field resolver yang datar ke metadata entity', () {
      final entity = SarprasModel.fromJson({
        ..._item,
        'keterangan': 'Butuh lapangan',
        'resolved_by_akses': 'Kesiswaan',
        'resolved_by_nip': '198001012005011002',
        'resolved_by_nama': 'Budi Santoso',
        'alasan_tolak': null,
        'resolved_at': '2026-07-21T08:30:00.000Z',
        'created_at': '2026-07-19T10:00:00.000Z',
        'updated_at': '2026-07-21T08:30:00.000Z',
      }).toEntity();

      expect(entity.metadata, isNotNull);
      expect(entity.metadata!.keterangan, 'Butuh lapangan');
      expect(entity.metadata!.aksesResolver, 'Kesiswaan');
      expect(entity.metadata!.nameResolver, 'Budi Santoso');
      expect(entity.metadata!.resolvedAt, DateTime.utc(2026, 7, 21, 8, 30));
    });
  });

  group('SarprasResponse.fromJson', () {
    test('memetakan ringkasan berbahasa Indonesia ke field summary', () {
      final response = SarprasResponse.fromJson({
        'error': false,
        'ringkasan': {'Menunggu': 3, 'Disetujui': 2, 'Ditolak': 1},
        'data': [_item],
      });

      expect(response.summary.waiting, 3);
      expect(response.summary.accepted, 2);
      expect(response.summary.rejected, 1);
      expect(response.listSarpras, hasLength(1));
    });
  });

  group('SarprasDetailResponse.fromJson', () {
    test('membuka envelope dan mengisi sarpras', () {
      final response = SarprasDetailResponse.fromJson({
        'error': false,
        'message': 'Permohonan izin berhasil diajukan',
        'data': _item,
      });

      expect(response.sarpras, isNotNull);
      expect(response.sarpras!.id, 12);
    });

    test('mengembalikan sarpras null saat data kosong', () {
      final response = SarprasDetailResponse.fromJson({
        'error': false,
        'data': null,
      });

      expect(response.sarpras, isNull);
    });

    test('mengurai respons store asli dari server', () {
      final response = SarprasDetailResponse.fromJson({
        'error': false,
        'message':
            'Permohonan izin berhasil diajukan, menunggu persetujuan '
            'Kesiswaan/Kurikulum.',
        'data': {
          'unit': 'SMAKT',
          'NIS': '24251026',
          'tanggal_kegiatan': '2026-07-22T17:00:00.000000Z',
          'nama_kegiatan': 'Meeting IT',
          'jumlah_siswa_kelas': '5',
          'NIP_guru_pembimbing': '20250602',
          'waktu_kegiatan': '12.00 - 15.00',
          'keterangan': 'Meeting Bulanan Team IT',
          'status': 'Menunggu',
          'updated_at': '2026-07-22T04:40:14.000000Z',
          'created_at': '2026-07-22T04:40:14.000000Z',
          'id': 4,
        },
      });

      final entity = response.sarpras!.toEntity();

      expect(entity.id, 4);
      expect(entity.nipGuruPembimbing, '20250602');
      expect(entity.waktuKegiatan, '12.00 - 15.00');
      expect(entity.metadata!.keterangan, 'Meeting Bulanan Team IT');
      expect(entity.metadata!.createdAt, isNotNull);
      expect(entity.metadata!.resolvedAt, isNull);
    });
  });

  group('SarprasParams.toRequest', () {
    test('mengirim jam sebagai HH:mm, bukan ISO8601', () {
      final request = SarprasParams(
        tanggalKegiatan: DateTime(2026, 7, 23),
        namaKegiatan: 'Meeting IT',
        jumlahSiswaDalamKegiatan: '5',
        nipGuruPembimbing: '20250602',
        jamMulaiKegiatan: DateTime(2026, 7, 23, 12),
        jamSelesaiKegiatan: DateTime(2026, 7, 23, 15),
        keterangan: 'Meeting Bulanan Team IT',
      ).toRequest().toJson();

      expect(request['jam_mulai'], '12:00');
      expect(request['jam_selesai'], '15:00');
      expect(request['NIP_guru_pembimbing'], '20250602');
      expect(request['jumlah_siswa_kelas'], '5');
    });

    test('mengirim tanggal tanpa penanda zona waktu', () {
      final request = SarprasParams(
        tanggalKegiatan: DateTime(2026, 7, 23),
        namaKegiatan: 'Meeting IT',
        jumlahSiswaDalamKegiatan: '5',
        nipGuruPembimbing: '20250602',
        jamMulaiKegiatan: DateTime(2026, 7, 23, 12),
        jamSelesaiKegiatan: DateTime(2026, 7, 23, 15),
      ).toRequest().toJson();

      expect(request['tanggal_kegiatan'], startsWith('2026-07-23T00:00:00'));
      expect(request['tanggal_kegiatan'], isNot(endsWith('Z')));
    });
  });
}
