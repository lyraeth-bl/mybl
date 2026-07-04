// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/attendance/domain/attendance_rules.dart';
import 'package:my_bl/features/attendance/domain/entities/attendance_entity/attendance_entity.dart';

AttendanceEntity _entity({DateTime? checkIn, DateTime? checkOut}) {
  final day = DateTime(2026, 7, 6);

  return AttendanceEntity(
    id: 1,
    nis: '123',
    tajaran: '2025/2026',
    semester: '1',
    tanggal: day,
    jamCheckIn: checkIn,
    jamCheckOut: checkOut,
    status: 'Hadir',
    unit: 'SMA',
    createdAt: day,
    updatedAt: day,
  );
}

void main() {
  final beforeCutoff = DateTime(2026, 7, 6, 12, 59);
  final atCutoff = DateTime(2026, 7, 6, 13);
  final afterCutoff = DateTime(2026, 7, 6, 15);

  test('no record yet -> checkIn', () {
    expect(
      resolveAttendanceQrAction(null, beforeCutoff),
      AttendanceQrAction.checkIn,
    );
  });

  test('checked in, before cutoff -> alreadyCheckedIn', () {
    final entity = _entity(checkIn: DateTime(2026, 7, 6, 6, 30));
    expect(
      resolveAttendanceQrAction(entity, beforeCutoff),
      AttendanceQrAction.alreadyCheckedIn,
    );
  });

  test('checked in, exactly at cutoff -> checkOut', () {
    final entity = _entity(checkIn: DateTime(2026, 7, 6, 6, 30));
    expect(
      resolveAttendanceQrAction(entity, atCutoff),
      AttendanceQrAction.checkOut,
    );
  });

  test('checked in, after cutoff -> checkOut', () {
    final entity = _entity(checkIn: DateTime(2026, 7, 6, 6, 30));
    expect(
      resolveAttendanceQrAction(entity, afterCutoff),
      AttendanceQrAction.checkOut,
    );
  });

  test('checked in and out -> done, regardless of time', () {
    final entity = _entity(
      checkIn: DateTime(2026, 7, 6, 6, 30),
      checkOut: DateTime(2026, 7, 6, 11),
    );
    expect(
      resolveAttendanceQrAction(entity, beforeCutoff),
      AttendanceQrAction.done,
    );
    expect(
      resolveAttendanceQrAction(entity, afterCutoff),
      AttendanceQrAction.done,
    );
  });
}
