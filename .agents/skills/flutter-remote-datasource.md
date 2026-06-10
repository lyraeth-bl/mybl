# Flutter Remote DataSource Pattern

## Overview

Use this skill when creating a remote data source in the data layer.
Trigger: user mentions "buat remote datasource", "create remote datasource", or after model creation.

## Before Writing Any Code

Ask the user:

1. "Method apa aja yang dibutuhin di remote datasource ini?"
2. "Tiap method pakai HTTP method apa? (GET/POST/PUT/DELETE)"
3. "Ada query parameters atau request body yang perlu dikirim?"

## File Location

```
lib/features/<feature_name>/data/datasources/<feature_name>_remote_data_source.dart
```

## Structure

Every remote datasource has two classes in one file:

1. `abstract class` — defines the contract (what methods exist)
2. `class Impl implements abstract` — the actual implementation

## File Template

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
// import response models here

abstract class <FeatureName>RemoteDataSource {
  // method contracts here
}

class <FeatureName>RemoteDataSourceImpl implements <FeatureName>RemoteDataSource {
  <FeatureName>RemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  // method implementations here
}
```

## Rules

- Always inject `HTTPRequest` (from `data_interfaces.dart`) — never inject a concrete HTTP client
- Always return Response/DTO Models — never return entities or raw maps
- Always use `async`/`await`
- For POST/PUT, always call `.toJson()` on the request model before passing to `_httpRequest`
- For GET with query params, always define query as `final Map<String, dynamic> query = {...}` first
- Use `ApiEndpoints.someName` as placeholder — let the user fill in the correct endpoint name
- For methods returning `Unit` (e.g. logout), return `unit` after the request completes

## HTTP Method Guide

| Operation          | HTTP Method | \_httpRequest call                                   |
| ------------------ | ----------- | ---------------------------------------------------- |
| Fetch data         | GET         | `_httpRequest.get(endpoint)`                         |
| Fetch with filters | GET         | `_httpRequest.get(endpoint, queryParameters: query)` |
| Create data        | POST        | `_httpRequest.post(endpoint, data: request)`         |
| Update data        | PUT         | `_httpRequest.put(endpoint, data: request)`          |
| Delete data        | DELETE      | `_httpRequest.delete(endpoint)`                      |

## Examples

### GET only

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/app_configuration_response/app_configuration_response.dart';

abstract class AppConfigurationRemoteDataSource {
  Future<AppConfigurationResponse> fetch();
}

class AppConfigurationRemoteDataSourceImpl
    implements AppConfigurationRemoteDataSource {
  AppConfigurationRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<AppConfigurationResponse> fetch() async {
    final response = await _httpRequest.get(ApiEndpoints.appConfig);

    return AppConfigurationResponse.fromJson(response);
  }
}
```

### GET with query parameters

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/monthly_attendance_response/monthly_attendance_response.dart';
import '../models/daily_attendance_response/daily_attendance_response.dart';

abstract class AttendanceRemoteDataSource {
  Future<MonthlyAttendanceResponse> fetchMonthlyAttendance({
    required int month,
    required int year,
  });

  Future<DailyAttendanceResponse> fetchDailyAttendance();
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  AttendanceRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<DailyAttendanceResponse> fetchDailyAttendance() async {
    final response = await _httpRequest.get(ApiEndpoints.todayAttendance);

    return DailyAttendanceResponse.fromJson(response);
  }

  @override
  Future<MonthlyAttendanceResponse> fetchMonthlyAttendance({
    required int month,
    required int year,
  }) async {
    final Map<String, dynamic> query = {'month': month, 'year': year};

    final response = await _httpRequest.get(
      ApiEndpoints.attendance,
      queryParameters: query,
    );

    return MonthlyAttendanceResponse.fromJson(response);
  }
}
```

### POST and DELETE

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/auth_response_model/auth_response_model.dart';
import '../models/login_request/login_request.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequest data);
  Future<Unit> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<AuthResponseModel> login(LoginRequest data) async {
    final request = data.toJson();

    final response = await _httpRequest.post(ApiEndpoints.login, data: request);

    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<Unit> logout() async {
    await _httpRequest.post(ApiEndpoints.logout, data: {});

    return unit;
  }
}
```

## Anti-patterns

- DO NOT inject concrete HTTP clients (Dio, http) directly — always use `HTTPRequest`
- DO NOT return raw `Map` or entities — always return Response/DTO Models
- DO NOT skip `async`/`await`
- DO NOT put business logic or error handling here — that belongs in the repository impl
- DO NOT skip the copyright header
