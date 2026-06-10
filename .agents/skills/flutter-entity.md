# Flutter Entity Pattern

## Overview

Use this skill every time a new entity is being created for a feature.
Trigger: user mentions "create entity", "buat entity", or starts defining domain fields for a feature.

## Before Writing Any Code

Always ask the user for the API response structure or DB fields first.
Prioritize API response fields over DB fields if both are available.

## File Location

```
lib/features/<feature_name>/domain/entities/<entity_name>/<entity_name>.dart
```

Use the real entity name, not always the feature name. Examples in this project:

- `student_entity/student_entity.dart`
- `auth_response_entity/auth_response_entity.dart`
- `login_params/login_params.dart`
- `attendance_summary/attendance_summary.dart`
- `attendance_status/attendance_status.dart`

## File Template

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part '<feature_name>_entity.freezed.dart';

@freezed
abstract class <FeatureName>Entity with _$<FeatureName>Entity {
  const factory <FeatureName>Entity({
    // fields here
  }) = _<FeatureName>Entity;
}
```

## Rules

- ALWAYS use `@freezed` with `abstract class` — no exceptions
- ALWAYS add the copyright header at the top of the file
- Use `required Type fieldName` for fields that are never null
- Use `Type? fieldName` for nullable fields
- Use `@Default(value)` when the domain value should have a safe default
- NEVER add `fromJson` or `toJson` factory inside the entity
- NEVER add IO, validation flow, repository calls, or application workflow logic
  inside the entity
- Simple deterministic derived getters are allowed when they only use the
  entity's own fields, as in `AttendanceSummary.total` and
  `AttendanceSummary.attendanceRate`
- If the domain concept is a closed set of constants, a plain `enum` is allowed,
  as in `AttendanceStatus`

## After Creating the File

Always run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Example (feature: attendance)

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_entity.freezed.dart';

@freezed
abstract class AttendanceEntity with _$AttendanceEntity {
  const factory AttendanceEntity({
    required int id,
    required String nis,
    required String tajaran,
    required String semester,
    required DateTime tanggal,
    DateTime? jamCheckIn,
    DateTime? jamCheckOut,
    required String status,
    String? alasan,
    required String unit,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AttendanceEntity;
}
```

## Anti-patterns

- DO NOT use regular `class` — always `abstract class` with `@freezed`
- DO NOT add `fromJson` / `toJson` in the entity layer
- DO NOT put IO or application workflow logic inside the entity
- DO NOT skip the copyright header
- DO NOT skip running build_runner after file creation
