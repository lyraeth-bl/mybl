# Flutter Dependency Injection Pattern

## Overview

Use this skill when filling in the `init<FeatureName>DI()` function in the feature's DI file.
Trigger: user mentions "isi DI", "setup DI", "daftarin DI", or after BLoC creation.

## File Location

```
lib/features/<feature_name>/<feature_name>_di.dart
```

## Registration Order

Preferred order for new feature DI is from the lowest layer to the highest:

1. Local DataSource
2. Remote DataSource
3. Repository
4. Use Cases
5. BLoC / Cubit

This order follows the dependency graph and is easiest to read.

Existing project files are mixed: some register repositories before data
sources because `registerLazySingleton` stores a factory and resolves
dependencies later. Do not reorder existing DI only for style. When editing an
existing DI file, preserve the local ordering style unless it is causing a real
bug.

## registerLazySingleton vs registerFactory

| Type                    | Use                                          | Reason                                                       |
| ----------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| `registerLazySingleton` | DataSource, Repository, UseCase, global/shared BLoC | Created once, reused everywhere                        |
| `registerFactory`       | Per-screen BLoC / Cubit                            | New instance per screen, auto-disposed when screen is popped |

### What counts as global BLoC?

A BLoC is global if it manages app-wide state that must persist across screens.
Examples: `SessionBloc`, `AppConfigurationBloc`.
If in doubt, ask the user.

`UserBloc` is registered as a lazy singleton in the current project because its
state is shared by multiple screens, including profile-related screens.

## Storage Backend Injection

| Backend              | Inject via                   |
| -------------------- | ---------------------------- |
| Hive                 | `di<HiveInterface>()`        |
| FlutterSecureStorage | `di<FlutterSecureStorage>()` |
| HTTP                 | `di<HTTPRequest>()`          |

These are pre-registered globally — never register them inside feature DI.

## File Template

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../core/di/get_it_constant.dart';
// other imports

void init<FeatureName>DI() {
  // 1. Local DataSource
  di.registerLazySingleton<<FeatureName>LocalDataSource>(
    () => <FeatureName>LocalDataSourceImpl(di</* backend */>()),
  );

  // 2. Remote DataSource
  di.registerLazySingleton<<FeatureName>RemoteDataSource>(
    () => <FeatureName>RemoteDataSourceImpl(di<HTTPRequest>()),
  );

  // 3. Repository
  di.registerLazySingleton<<FeatureName>Repository>(
    () => <FeatureName>RepositoryImpl(
      di<<FeatureName>LocalDataSource>(),
      di<<FeatureName>RemoteDataSource>(),
    ),
  );

  // 4. Use Cases
  di.registerLazySingleton<<FeatureName>UseCase>(
    () => <FeatureName>UseCase(di<<FeatureName>Repository>()),
  );

  // 5. BLoC / Cubit
  di.registerFactory<<FeatureName>Bloc>(
    () => <FeatureName>Bloc(di<<FeatureName>UseCase>()),
  );
}
```

## Examples

### Feature with local + remote (per-screen BLoC)

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:hive_ce/hive_ce.dart';

import '../../core/di/get_it_constant.dart';
import '../../core/internal/src/interfaces/data_interfaces.dart';
import 'data/datasources/user_local_data_source.dart';
import 'data/datasources/user_remote_data_source.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/usecases/fetch_student_use_case.dart';
import 'presentation/bloc/user_bloc.dart';

void initUserDI() {
  di.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(di<HiveInterface>()),
  );
  di.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      di<UserLocalDataSource>(),
      di<UserRemoteDataSource>(),
    ),
  );

  di.registerLazySingleton<FetchStudentUseCase>(
    () => FetchStudentUseCase(di<UserRepository>()),
  );

  di.registerFactory<UserBloc>(
    () => UserBloc(di<FetchStudentUseCase>()),
  );
}
```

### Feature with local only + global BLoC

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/di/get_it_constant.dart';
import 'data/datasources/session_local_data_source.dart';
import 'data/repositories/session_repository_impl.dart';
import 'domain/repositories/session_repository.dart';
import 'domain/usecases/clear_access_token_use_case.dart';
import 'domain/usecases/read_access_token_use_case.dart';
import 'domain/usecases/save_access_token_use_case.dart';
import 'presentation/bloc/session_bloc.dart';

void initSessionsDI() {
  di.registerLazySingleton<SessionLocalDataSource>(
    () => SessionLocalDataSourceImpl(di<FlutterSecureStorage>()),
  );

  di.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(di<SessionLocalDataSource>()),
  );

  di.registerLazySingleton<SaveAccessTokenUseCase>(
    () => SaveAccessTokenUseCase(di<SessionRepository>()),
  );
  di.registerLazySingleton<ReadAccessTokenUseCase>(
    () => ReadAccessTokenUseCase(di<SessionRepository>()),
  );
  di.registerLazySingleton<ClearAccessTokenUseCase>(
    () => ClearAccessTokenUseCase(di<SessionRepository>()),
  );

  // Global BLoC — LazySingleton because it manages app-wide session state
  di.registerLazySingleton<SessionBloc>(
    () => SessionBloc(
      di<SaveAccessTokenUseCase>(),
      di<ReadAccessTokenUseCase>(),
      di<ClearAccessTokenUseCase>(),
      di<ClearAllBoxesUseCase>(),
    ),
  );
}
```

### Feature with multiple BLoCs

```dart
void initAttendanceDI() {
  di.registerLazySingleton<AttendanceLocalDataSource>(
    () => AttendanceLocalDataSourceImpl(di<HiveInterface>()),
  );
  di.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      di<AttendanceRemoteDataSource>(),
      di<AttendanceLocalDataSource>(),
    ),
  );

  di.registerLazySingleton<FetchDailyAttendanceUseCase>(
    () => FetchDailyAttendanceUseCase(di<AttendanceRepository>()),
  );
  di.registerLazySingleton<FetchMonthlyAttendanceUseCase>(
    () => FetchMonthlyAttendanceUseCase(di<AttendanceRepository>()),
  );

  di.registerFactory<DailyAttendanceBloc>(
    () => DailyAttendanceBloc(di<FetchDailyAttendanceUseCase>()),
  );
  di.registerFactory<MonthlyAttendanceBloc>(
    () => MonthlyAttendanceBloc(di<FetchMonthlyAttendanceUseCase>()),
  );
}
```

## Anti-patterns

- Prefer DataSource registration before Repository registration in new DI files,
  unless you are matching an existing local file style
- DO NOT reorder existing registrations only for style
- DO NOT use `registerFactory` for DataSources, Repositories, or UseCases
- DO NOT use `registerLazySingleton` for per-screen BLoCs
- DO NOT inject `HiveInterface`, `HTTPRequest`, or `FlutterSecureStorage` manually — always via `di<>`
- DO NOT skip the copyright header
