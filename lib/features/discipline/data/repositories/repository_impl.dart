// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/discipline.dart';
import '../../domain/repositories/repository.dart';
import '../datasources/local.dart';
import '../datasources/remote.dart';
import '../models/discipline_model/discipline_model.dart';

class DisciplineRepositoryImpl implements DisciplineRepository {
  DisciplineRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final DisciplineLocalDataSource _localDataSource;
  final DisciplineRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<DemeritEntity>?>> fetchDemerit({
    String? schoolSession,
    String? semester,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final storedListData = _localDataSource.readListDemerit();

      if (storedListData != null) {
        final storedData = storedListData.map((m) => m.toEntity()).toList();

        return right(storedData);
      }
    }

    try {
      final response = await _remoteDataSource.fetchDemerit(
        schoolSession: schoolSession,
        semester: semester,
      );

      if (response.listDemerit == null) return right(null);

      await _localDataSource.saveListDemerit(response.listDemerit!);

      final convertToEntity = response.listDemerit!
          .map((m) => m.toEntity())
          .toList();

      return right(convertToEntity);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<List<MeritEntity>?>> fetchMerit({
    String? schoolSession,
    String? semester,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final storedListData = _localDataSource.readListMerit();

      if (storedListData != null) {
        final storedData = storedListData.map((m) => m.toEntity()).toList();

        return right(storedData);
      }
    }

    try {
      final response = await _remoteDataSource.fetchMerit(
        schoolSession: schoolSession,
        semester: semester,
      );

      if (response.listMerit == null) return right(null);

      await _localDataSource.saveListMerit(response.listMerit!);

      final convertToEntity = response.listMerit!
          .map((m) => m.toEntity())
          .toList();

      return right(convertToEntity);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
