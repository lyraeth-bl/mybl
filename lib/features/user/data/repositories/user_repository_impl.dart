// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/student_entity/student_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/student_model/student_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final UserLocalDataSource _localDataSource;
  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<Result<StudentEntity>> fetch([bool forceRefresh = false]) async {
    if (!forceRefresh) {
      final storedData = _localDataSource.read();

      if (storedData != null) return right(storedData.toEntity());
    }

    try {
      final response = await _remoteDataSource.fetch();

      await _localDataSource.save(response.student);

      return right(response.student.toEntity());
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
