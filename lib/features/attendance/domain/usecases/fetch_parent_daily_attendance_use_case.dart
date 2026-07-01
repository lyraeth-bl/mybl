// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/attendance_entity/attendance_entity.dart';
import '../repositories/parent_attendance_repository.dart';

class FetchParentDailyAttendanceUseCase {
  FetchParentDailyAttendanceUseCase(this._parentAttendanceRepository);

  final ParentAttendanceRepository _parentAttendanceRepository;

  Future<Result<AttendanceEntity?>> call([bool forceRefresh = false]) =>
      _parentAttendanceRepository.fetchDailyAttendance(forceRefresh);
}
