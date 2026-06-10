# Flutter Use Case Pattern

## Overview

Use this skill when creating use cases for a feature in the domain layer.
Trigger: user mentions "buat use case", "create use case", or after domain repository is created.

## How Many Use Cases?

Each method in the domain repository gets its own use case class and file.
Example: `AuthRepository` has `login()` and `logout()` → 2 use cases, 2 files.

## File Location

```
lib/features/<feature_name>/domain/usecases/<function_name>_use_case.dart
```

### Naming Convention

File name follows the repository method name in snake_case:

- `login` → `login_use_case.dart`
- `logout` → `logout_use_case.dart`
- `readNIS` → `read_nis_use_case.dart`
- `fetchDailyAttendance` → `fetch_daily_attendance_use_case.dart`

## File Template

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '<repository_import>';

class <FunctionName>UseCase {
  <FunctionName>UseCase(this._<featureName>Repository);

  final <FeatureName>Repository _<featureName>Repository;

  Future<Result<<ReturnType>>> call(<params>) =>
      _<featureName>Repository.<methodName>(<args>);
}
```

## Rules

- ALWAYS use `call()` method — never use custom method names
- NEVER use `async`/`await` — always use direct method forwarding
- One use case class per repository method
- One file per use case

## Params: When to Create vs Not

### Direct params

Use direct params for simple methods with no input or a small number of
unrelated input fields. Examples: `forceRefresh`, `month`, `year`.

```dart
class FetchMonthlyAttendanceUseCase {
  FetchMonthlyAttendanceUseCase(this._attendanceRepository);
  final AttendanceRepository _attendanceRepository;

  Future<Result<List<AttendanceEntity>>> call({
    required int month,
    required int year,
    bool forceRefresh = false,
  }) => _attendanceRepository.fetchMonthlyAttendance(
        month: month,
        year: year,
        forceRefresh: forceRefresh,
      );
}
```

### Params entity

Create a Params entity and pass it to `call()` when:

- The use case needs more than 3 fields.
- A matching request value already exists.
- The input is a cohesive form/request value, such as login credentials.

The existing auth feature uses `LoginParams` even though it has only `nis` and
`password`, because those fields belong together as one login request.

```dart
class CreateSomethingUseCase {
  CreateSomethingUseCase(this._somethingRepository);
  final SomethingRepository _somethingRepository;

  Future<Result<SomethingEntity>> call(CreateSomethingParams params) =>
      _somethingRepository.createSomething(params);
}
```

When params are needed, two additional files must be created:

1. `domain/entities/<params_name>/<params_name>.dart` → `@freezed`, no `fromJson/toJson`
2. `data/models/<request_name>/<request_name>.dart` → `@freezed`, with `fromJson`

Refer to the **flutter-entity** and **flutter-model** skills for how to create these files.

## Examples

### No input needed

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  LogoutUseCase(this._authRepository);
  final AuthRepository _authRepository;

  Future<Result<Unit>> call() => _authRepository.logout();
}
```

### With Params entity (login style used in this project)

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/auth_response_entity/auth_response_entity.dart';
import '../entities/login_params/login_params.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._authRepository);
  final AuthRepository _authRepository;

  Future<Result<AuthResponseEntity>> call(LoginParams params) =>
      _authRepository.login(nis: params.nis, password: params.password);
}
```

## After Creating Use Case Files

Always run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Only needed if Params class was created (triggers `@freezed` generation).
Skip if no Params class was created.

## Anti-patterns

- DO NOT use `async`/`await`
- DO NOT use custom method names — always `call()`
- DO NOT put business logic inside the use case
- DO NOT create a single use case file for multiple repository methods
- DO NOT create a Params class for unrelated simple inputs; use it only for
  cohesive request/form values or larger parameter sets
- DO NOT skip the copyright header
