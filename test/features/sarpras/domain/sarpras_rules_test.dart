// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras/sarpras.dart';
import 'package:my_bl/features/sarpras/domain/sarpras_rules.dart';

Sarpras _sarpras({required String status}) => Sarpras(
  id: 1,
  unit: 'SMAKT',
  nis: '24251026',
  tanggalKegiatan: DateTime(2026, 7, 23),
  namaKegiatan: 'Meeting IT',
  jumlahSiswaDalamKegiatan: '5',
  nipGuruPembimbing: '20250602',
  waktuKegiatan: '12.00 - 15.00',
  status: status,
);

void main() {
  test('isCancelable is true only while the request is pending', () {
    expect(_sarpras(status: 'Menunggu').isCancelable, isTrue);
    expect(_sarpras(status: 'Disetujui').isCancelable, isFalse);
    expect(_sarpras(status: 'Ditolak').isCancelable, isFalse);
  });

  test('a time range is valid only when the end is strictly later', () {
    expect(
      isSarprasTimeRangeValid(startMinutes: 12 * 60, endMinutes: 15 * 60),
      isTrue,
    );
    expect(
      isSarprasTimeRangeValid(startMinutes: 12 * 60, endMinutes: 12 * 60),
      isFalse,
    );
    expect(
      isSarprasTimeRangeValid(startMinutes: 15 * 60, endMinutes: 12 * 60),
      isFalse,
    );
  });
}
