// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/attendance_entity/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class FetchDailyAttendanceUseCase {
  FetchDailyAttendanceUseCase(this._attendanceRepository);

  final AttendanceRepository _attendanceRepository;

  Future<Result<AttendanceEntity>> call([bool forceRefresh = false]) =>
      _attendanceRepository.fetchDailyAttendance(forceRefresh);
}
