// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/attendance_entity/attendance_entity.dart';
import '../repositories/parent_attendance_repository.dart';

class FetchParentMonthlyAttendanceUseCase {
  FetchParentMonthlyAttendanceUseCase(this._parentAttendanceRepository);

  final ParentAttendanceRepository _parentAttendanceRepository;

  Future<Result<List<AttendanceEntity>>> call({
    required int month,
    required int year,
    bool forceRefresh = false,
  }) => _parentAttendanceRepository.fetchMonthlyAttendance(
    month: month,
    year: year,
    forceRefresh: forceRefresh,
  );
}
