# Flutter Local DataSource Pattern

## Overview

Use this skill when creating a local data source in the data layer.
Trigger: user mentions "buat local datasource", "create local datasource", or after remote datasource creation.

## Before Writing Any Code

Ask the user:

1. "Data apa yang perlu disimpen secara lokal?"
2. "Data ini sensitif (kayak token) atau data biasa (model/cache)?"

Based on the answer, determine which storage backend to use.

## File Location

```
lib/features/<feature_name>/data/datasources/<feature_name>_local_data_source.dart
```

## Storage Backend Rules

| Data type                      | Backend                | Inject                                |
| ------------------------------ | ---------------------- | ------------------------------------- |
| Sensitive (token, credentials) | `FlutterSecureStorage` | `FlutterSecureStorage _secureStorage` |
| Regular (model, cache)         | `HiveInterface`        | `HiveInterface _hiveInterface`        |

## Structure

Every local datasource has two classes in one file:

1. `abstract class` — implements a `LocalManager` or `CacheStorage` interface from `data_interfaces.dart`
2. `class Impl implements abstract` — the actual implementation

## File Template (Hive)

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';
// import model here

abstract class <FeatureName>LocalDataSource
    implements <Interface><<Model>> {}

class <FeatureName>LocalDataSourceImpl implements <FeatureName>LocalDataSource {
  <FeatureName>LocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  // implementations here
}
```

## File Template (FlutterSecureStorage)

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/secure_storage_names.dart';

abstract class <FeatureName>LocalDataSource implements <Interface> {}

class <FeatureName>LocalDataSourceImpl implements <FeatureName>LocalDataSource {
  <FeatureName>LocalDataSourceImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  // implementations here
}
```

## Rules

- Always implement a `LocalManager` or `CacheStorage` interface — never define raw methods
- Always inject the correct storage backend based on data sensitivity
- For Hive: always call `Map<String, dynamic>.from(rawData)` before `fromJson` when reading
- For Hive: always call `.toJson()` before saving a model
- For list data in Hive: cast to `List<dynamic>` then map each item through `fromJson`
- Always return `unit` after successful write operations
- Storage key names (`HiveStorageBoxNames`, `HiveStorageNames`, `SecureStorageNames`) are placeholders — let the user fill them in
- If a feature needs dynamic keys (e.g. per date or per month/year), create private helper methods that generate the key string

## Examples

### Simple CacheStorage (single model, Hive)

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';
import '../models/app_configuration_model/app_configuration_model.dart';

abstract class AppConfigurationLocalDataSource
    implements CacheStorage<AppConfigurationModel> {}

class AppConfigurationLocalDataSourceImpl
    implements AppConfigurationLocalDataSource {
  AppConfigurationLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  @override
  AppConfigurationModel? read() {
    final rawData = _hiveInterface
        .box(HiveStorageBoxNames.appBoxKey)
        .get(HiveStorageNames.appConfigurationKey);

    if (rawData == null) return null;

    return AppConfigurationModel.fromJson(Map<String, dynamic>.from(rawData));
  }

  @override
  Future<Unit> save(AppConfigurationModel data) async {
    await _hiveInterface
        .box(HiveStorageBoxNames.appBoxKey)
        .put(HiveStorageNames.appConfigurationKey, data.toJson());

    return unit;
  }
}
```

### Custom LocalManager (complex keys, Hive)

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';
import '../models/attendance_model/attendance_model.dart';

abstract class AttendanceLocalDataSource
    implements AttendanceLocalManager<AttendanceModel> {}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  AttendanceLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  String _generateMonthlyKey(int month, int year) =>
      '${HiveStorageNames.userMonthlyAttendanceKey}_${year}_$month';

  String _generateDailyKey() {
    final now = DateTime.now();
    return '${HiveStorageNames.userDailyAttendanceKey}_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
  }

  @override
  AttendanceModel? readDailyAttendance() {
    final rawData = _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .get(_generateDailyKey());

    if (rawData == null) return null;

    return AttendanceModel.fromJson(Map<String, dynamic>.from(rawData));
  }

  @override
  List<AttendanceModel>? readMonthlyAttendance({
    required int month,
    required int year,
  }) {
    final rawListData = _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .get(_generateMonthlyKey(month, year));

    if (rawListData == null) return null;

    return (rawListData as List<dynamic>?)
        ?.map((e) => AttendanceModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<Unit> saveDailyAttendance(AttendanceModel data) async {
    await _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .put(_generateDailyKey(), data.toJson());

    return unit;
  }

  @override
  Future<Unit> saveMonthlyAttendance({
    required int month,
    required int year,
    required List<AttendanceModel> listData,
  }) async {
    await _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .put(_generateMonthlyKey(month, year),
            listData.map((e) => e.toJson()).toList());

    return unit;
  }
}
```

### Secure Storage (token)

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/secure_storage_names.dart';

abstract class SessionLocalDataSource implements TokenStorage {}

class SessionLocalDataSourceImpl implements SessionLocalDataSource {
  SessionLocalDataSourceImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<Unit> clearAccessToken() async {
    await _secureStorage.delete(key: SecureStorageNames.accessTokenKey);

    return unit;
  }

  @override
  Future<String?> readAccessToken() async {
    final rawData = await _secureStorage.read(
      key: SecureStorageNames.accessTokenKey,
    );

    if (rawData == null) return null;

    return rawData;
  }

  @override
  Future<Unit> saveAccessToken(String accessToken) async {
    await _secureStorage.write(
      key: SecureStorageNames.accessTokenKey,
      value: accessToken,
    );

    return unit;
  }
}
```

## Anti-patterns

- DO NOT inject `HiveInterface` for sensitive data — use `FlutterSecureStorage`
- DO NOT define raw methods — always implement from an interface
- DO NOT forget `Map<String, dynamic>.from(rawData)` when reading from Hive
- DO NOT forget `.toJson()` when saving to Hive
- DO NOT hardcode storage key strings — always use `HiveStorageNames` / `SecureStorageNames`
- DO NOT skip the copyright header
