// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/time_table/time_table.dart';
import '../repositories/repository.dart';

class FetchTimeTableUseCase {
  FetchTimeTableUseCase(this._timeTableRepository);

  final TimeTableRepository _timeTableRepository;

  String _normalizeKelas(String kelas) {
    String result = kelas;
    if (result.isNotEmpty && result.endsWith("1")) {
      result = result.substring(0, result.length - 1);
    }
    if (result.startsWith("XIIANIMASI")) return "XIIANI";
    if (result.startsWith("XIANIMASI")) return "XIANI";
    if (result.startsWith("XANIMASI")) return "XANI";
    return result;
  }

  Future<Result<List<TimeTable>>> call([
    bool forceRefresh = false,
    String kelas = "",
  ]) {
    final normalizedKelas = _normalizeKelas(kelas);
    return _timeTableRepository.fetchAll(forceRefresh, normalizedKelas);
  }
}
