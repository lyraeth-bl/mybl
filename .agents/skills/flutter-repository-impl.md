# Flutter Repository Implementation Pattern

## Overview

Use this skill when creating a repository implementation in the data layer.
Trigger: user mentions "buat repository impl", "create repo impl", or after datasource creation.

## File Location

```
lib/features/<feature_name>/data/repositories/<feature_name>_repository_impl.dart
```

## Three Variations

### 1. Remote + Local (with cache)

Use when: feature has both remote and local datasource, data is cached locally.

Flow:

1. If `forceRefresh` is false → check local first
2. If local has data → return immediately as entity
3. If local is empty or `forceRefresh` is true → fetch from remote
4. Save remote result to local
5. Return as entity
6. Wrap any remote error with `Failure.fromError(e, st)`

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/<feature_name>_entity/<feature_name>_entity.dart';
import '../../domain/repositories/<feature_name>_repository.dart';
import '../datasources/<feature_name>_local_data_source.dart';
import '../datasources/<feature_name>_remote_data_source.dart';

class <FeatureName>RepositoryImpl implements <FeatureName>Repository {
  <FeatureName>RepositoryImpl(this._localDataSource, this._remoteDataSource);

  final <FeatureName>LocalDataSource _localDataSource;
  final <FeatureName>RemoteDataSource _remoteDataSource;

  @override
  Future<Result<<FeatureName>Entity>> fetch([bool forceRefresh = false]) async {
    if (!forceRefresh) {
      final storedData = _localDataSource.read();
      if (storedData != null) return right(storedData.toEntity());
    }

    try {
      final response = await _remoteDataSource.fetch();
      await _localDataSource.save(response.<dataField>);
      return right(response.<dataField>.toEntity());
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
```

### 2. Remote Only

Use when: feature has no local cache, data always comes from remote.

Flow:

1. Build request model if needed
2. Call remote datasource
3. Convert response to entity
4. Wrap any error with `Failure.fromError(e, st)`

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/<feature_name>_entity/<feature_name>_entity.dart';
import '../../domain/repositories/<feature_name>_repository.dart';
import '../datasources/<feature_name>_remote_data_source.dart';

class <FeatureName>RepositoryImpl implements <FeatureName>Repository {
  <FeatureName>RepositoryImpl(this._remoteDataSource);

  final <FeatureName>RemoteDataSource _remoteDataSource;

  @override
  Future<Result<<FeatureName>Entity>> someMethod({
    required String param,
  }) async {
    try {
      final response = await _remoteDataSource.someMethod(param);
      return right(response.toEntity());
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
```

### 3. Local Only

Use when: feature only reads/writes to local storage, no remote involved.

Flow:

1. Delegate directly to local datasource
2. No try/catch needed
3. No `forceRefresh` needed

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../domain/repositories/<feature_name>_repository.dart';
import '../datasources/<feature_name>_local_data_source.dart';

class <FeatureName>RepositoryImpl implements <FeatureName>Repository {
  <FeatureName>RepositoryImpl(this._localDataSource);

  final <FeatureName>LocalDataSource _localDataSource;

  @override
  Future<Unit> save(String value) async =>
      await _localDataSource.save(value);

  @override
  Future<String?> read() async => await _localDataSource.read();

  @override
  Future<Unit> clear() async => await _localDataSource.clear();
}
```

## Rules

- Always implement the domain repository abstract class
- Always use `try/catch` for any method that calls remote datasource
- NEVER use `try/catch` for pure local methods
- Always wrap errors with `Failure.fromError(e, st)` — never throw raw exceptions
- Always convert models to entities before returning (`toEntity()`)
- `forceRefresh` parameter only exists if the method has a local cache
- If a feature mixes remote and local methods (like `AuthRepositoryImpl`),
  apply the correct pattern per method — not per class

## Mixed Example (Auth — remote + local methods in one class)

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/auth_response_entity/auth_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request/login_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  // Remote method — needs try/catch
  @override
  Future<Result<AuthResponseEntity>> login({
    required String nis,
    required String password,
  }) async {
    final request = LoginRequest(nis: nis, password: password);

    try {
      final response = await _remoteDataSource.login(request);
      return right(response.toEntity());
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  // Remote method — needs try/catch
  @override
  Future<Result<Unit>> logout() async {
    try {
      await _remoteDataSource.logout();
      return right(unit);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  // Local methods — no try/catch, direct delegation
  @override
  Future<String?> readNIS() async => await _localDataSource.readNIS();

  @override
  Future<Unit> saveNIS(String nis) async => await _localDataSource.saveNIS(nis);
}
```

## Anti-patterns

- DO NOT use `try/catch` on local-only methods
- DO NOT return raw models — always convert to entity with `toEntity()`
- DO NOT throw raw exceptions — always use `Failure.fromError(e, st)`
- DO NOT add `forceRefresh` if the method has no local cache
- DO NOT skip the copyright header
