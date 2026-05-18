// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_table.freezed.dart';

@freezed
abstract class TimeTable with _$TimeTable {
  const factory TimeTable({
    required String id,
    required String kelas,
    required String jamKe,
    required String jamMulai,
    required String jamSelesai,
    required String hari,
    required String namaGuru,
    required String namaMataPelajaran,
    required String kodeMataPelajaran,
  }) = _TimeTable;
}
