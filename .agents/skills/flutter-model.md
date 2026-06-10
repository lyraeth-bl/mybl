# Flutter Model Pattern

## Overview

Use this skill when creating model classes in the data layer.
Trigger: user mentions "buat model", "create model", or after entity creation when moving to the data layer.

## Before Writing Any Code

Always ask the user for the API response JSON first.
This is required to determine field names and which fields need `@JsonKey`.

## File Location

```
lib/features/<feature_name>/data/models/<model_name>/<model_name>.dart
```

## Two Roles of a Model

### 1. Base Model

Mirrors a domain entity. Always has `fromJson` + `toEntity()`.

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/<entity_name>/<entity_name>.dart';

part '<model_name>.freezed.dart';
part '<model_name>.g.dart';

@freezed
abstract class <ModelName> with _$<ModelName> {
  const factory <ModelName>({
    // fields here
  }) = _<ModelName>;

  factory <ModelName>.fromJson(Map<String, dynamic> json) =>
      _$<ModelName>FromJson(json);
}

extension <ModelName>Mapper on <ModelName> {
  <EntityName> toEntity() => <EntityName>(
    // map fields here
  );
}
```

### 2. Response/DTO Model

Wraps the full API response. Always has `fromJson`, NO `toEntity()`.
Its fields reference Base Models for nested data objects.

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part '<response_name>.freezed.dart';
part '<response_name>.g.dart';

@freezed
abstract class <ResponseName> with _$<ResponseName> {
  const factory <ResponseName>({
    required bool error,
    required String message,
    // data field references Base Model
  }) = _<ResponseName>;

  factory <ResponseName>.fromJson(Map<String, dynamic> json) =>
      _$<ResponseName>FromJson(json);
}
```

## @JsonKey Rules

### When to use @JsonKey(name: '...')

In this project, API-backed model fields use explicit `@JsonKey(name: '...')`
annotations. Existing models use `@JsonKey` even when the API key and Dart
field name are identical, for example `id`, `nis`, and `status`.

| API key        | Dart field          | Need @JsonKey? |
| -------------- | ------------------- | -------------- |
| `access_token` | `accessToken`       | ✅ Yes         |
| `created_at`   | `createdAt`         | ✅ Yes         |
| `checkIn`      | `jamCheckIn`        | ✅ Yes         |
| `data`         | `monthlyAttendance` | ✅ Yes         |
| `status`       | `status`            | ✅ Yes         |
| `id`           | `id`                | ✅ Yes         |

Use the quote style already used in the surrounding model file. Existing files
contain both single and double quotes; do not churn unrelated quote style.

### When to use @Default(value)

When the field is nullable in the API but needs a default value in Dart:

```dart
@JsonKey(name: 'force_update') @Default(false) bool forceUpdate,
```

## Examples

### Base Model

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/attendance_entity/attendance_entity.dart';

part 'attendance_model.freezed.dart';
part 'attendance_model.g.dart';

@freezed
abstract class AttendanceModel with _$AttendanceModel {
  const factory AttendanceModel({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "nis") required String nis,
    @JsonKey(name: "tajaran") required String tajaran,
    @JsonKey(name: "semester") required String semester,
    @JsonKey(name: "tanggal") required DateTime tanggal,
    @JsonKey(name: "checkIn") DateTime? jamCheckIn,
    @JsonKey(name: "checkOut") DateTime? jamCheckOut,
    @JsonKey(name: "status") required String status,
    @JsonKey(name: "alasan") String? alasan,
    @JsonKey(name: "unit") required String unit,
    @JsonKey(name: "created_at") required DateTime createdAt,
    @JsonKey(name: "updated_at") required DateTime updatedAt,
  }) = _AttendanceModel;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);
}

extension AttendanceModelMapper on AttendanceModel {
  AttendanceEntity toEntity() => AttendanceEntity(
    id: id,
    nis: nis,
    tajaran: tajaran,
    semester: semester,
    tanggal: tanggal,
    jamCheckIn: jamCheckIn,
    jamCheckOut: jamCheckOut,
    status: status,
    alasan: alasan,
    unit: unit,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
```

### Response/DTO Model (single object)

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../attendance_model/attendance_model.dart';

part 'daily_attendance_response.freezed.dart';
part 'daily_attendance_response.g.dart';

@freezed
abstract class DailyAttendanceResponse with _$DailyAttendanceResponse {
  const factory DailyAttendanceResponse({
    required bool error,
    required String message,
    @JsonKey(name: 'data') AttendanceModel? dailyAttendance,
  }) = _DailyAttendanceResponse;

  factory DailyAttendanceResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyAttendanceResponseFromJson(json);
}
```

### Response/DTO Model (list)

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../attendance_model/attendance_model.dart';

part 'monthly_attendance_response.freezed.dart';
part 'monthly_attendance_response.g.dart';

@freezed
abstract class MonthlyAttendanceResponse with _$MonthlyAttendanceResponse {
  const factory MonthlyAttendanceResponse({
    required bool error,
    required String message,
    @JsonKey(name: 'data') required List<AttendanceModel> monthlyAttendance,
  }) = _MonthlyAttendanceResponse;

  factory MonthlyAttendanceResponse.fromJson(Map<String, dynamic> json) =>
      _$MonthlyAttendanceResponseFromJson(json);
}
```

## After Creating Model Files

Always run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Anti-patterns

- DO NOT add `toEntity()` to Response/DTO Models
- DO NOT omit `@JsonKey` on API-backed model fields in new models
- DO NOT manually write `toJson()` — it is auto-generated via `.g.dart`
- DO NOT skip `part '<model_name>.g.dart'` — required for JSON generation
- DO NOT skip the copyright header
