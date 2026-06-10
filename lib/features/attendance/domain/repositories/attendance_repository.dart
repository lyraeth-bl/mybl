// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/internal/src/types.dart';
import '../entities/attendance_entity/attendance_entity.dart';
import '../entities/attendance_qr_token/attendance_qr_token.dart';

abstract class AttendanceRepository
    implements AttendanceFetcher<AttendanceEntity> {
  Future<Result<AttendanceQrToken>> fetchQrToken();
}
