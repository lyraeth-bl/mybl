// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/attendance_entity/attendance_entity.dart';

abstract class AttendanceRepository
    implements AttendanceFetcher<AttendanceEntity> {}
