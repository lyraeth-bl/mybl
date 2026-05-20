// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/attendance_qr_token/attendance_qr_token.dart';
import '../repositories/attendance_repository.dart';

class FetchAttendanceQrTokenUseCase {
  FetchAttendanceQrTokenUseCase(this._attendanceRepository);

  final AttendanceRepository _attendanceRepository;

  Future<Result<AttendanceQrToken>> call() =>
      _attendanceRepository.fetchQrToken();
}
