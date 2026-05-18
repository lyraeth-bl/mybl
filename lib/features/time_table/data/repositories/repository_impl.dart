// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/time_table/time_table.dart';
import '../../domain/repositories/repository.dart';
import '../datasources/local.dart';
import '../datasources/remote.dart';
import '../models/time_table/time_table_model.dart';

class TimeTableRepositoryImpl implements TimeTableRepository {
  TimeTableRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final TimeTableLocalDataSource _localDataSource;
  final TimeTableRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<TimeTable>>> fetchAll([
    bool forceRefresh = false,
    String kelas = "",
  ]) async {
    if (!forceRefresh) {
      final storedListData = _localDataSource.readListTimeTable();

      if (storedListData != null) {
        final storedData = storedListData.map((m) => m.toEntity()).toList();

        return right(storedData);
      }
    }

    try {
      final response = await _remoteDataSource.fetchAll(kelas: kelas);

      await _localDataSource.saveListTimeTable(
        listData: response.listTimeTable,
      );

      final convertToEntity = response.listTimeTable
          .map((m) => m.toEntity())
          .toList();

      return right(convertToEntity);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
