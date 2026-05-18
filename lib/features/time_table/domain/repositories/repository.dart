// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/time_table/time_table.dart';

abstract class TimeTableRepository {
  Future<Result<List<TimeTable>>> fetchAll([
    bool forceRefresh = false,
    String kelas = "",
  ]);
}
