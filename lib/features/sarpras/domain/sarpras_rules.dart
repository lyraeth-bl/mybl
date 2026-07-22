// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

/// Whether an activity's end time falls strictly after its start time.
///
/// Both values are minutes since midnight so the domain layer stays free
/// of Flutter's `TimeOfDay`. Presentation converts before calling.
bool isSarprasTimeRangeValid({
  required int startMinutes,
  required int endMinutes,
}) => endMinutes > startMinutes;
