// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'entities/attendance_entity/attendance_entity.dart';

/// Hour of day (24h) after which checkout becomes available.
///
/// Backend has no official checkout-window rule yet. SMA/SMK (the only
/// units this app currently serves) dismiss around 15:30; 13:00 gives a
/// ~2.5h buffer for early dismissal (sick leave, etc.) while blocking
/// same-morning checkout. Single place to change if BE ever provides a
/// real schedule-based rule.
const int attendanceCheckOutCutoffHour = 13;

/// Semantic state of the attendance QR action button, derived from
/// today's attendance record and the current time. Presentation maps
/// this to a localized label + enabled flag — this function has no
/// knowledge of strings or UI.
enum AttendanceQrAction { checkIn, alreadyCheckedIn, checkOut, done }

AttendanceQrAction resolveAttendanceQrAction(
  AttendanceEntity? entity,
  DateTime now,
) {
  if (entity?.jamCheckIn == null) return AttendanceQrAction.checkIn;
  if (entity!.jamCheckOut != null) return AttendanceQrAction.done;

  return now.hour >= attendanceCheckOutCutoffHour
      ? AttendanceQrAction.checkOut
      : AttendanceQrAction.alreadyCheckedIn;
}
