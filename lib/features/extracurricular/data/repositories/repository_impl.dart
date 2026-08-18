// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/extracurricular.dart';
import '../../domain/entities/extracurricular_attendance/extracurricular_attendance.dart';
import '../../domain/repositories/repository.dart';
import '../datasources/local.dart';
import '../datasources/remote.dart';
import '../mappers/extracurricular_attendance_model_mapper.dart';
import '../models/extracurricular/extracurricular.dart';

final class ExtracurricularRepositoryImpl implements ExtracurricularRepository {
  ExtracurricularRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final ExtracurricularLocalDataSource _localDataSource;
  final ExtracurricularRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<ExtracurricularEntity>>> fetchAll([
    bool forceRefresh = false,
  ]) async {
    if (!forceRefresh) {
      final storedListData = _localDataSource.read();

      if (storedListData != null) {
        final storedData = storedListData.map((m) => m.toEntity()).toList();

        return right(storedData);
      }
    }

    try {
      final response = await _remoteDataSource.fetchAll();

      await _localDataSource.save(response.listExtracurricular);

      final convertToEntity = response.listExtracurricular
          .map((m) => m.toEntity())
          .toList();

      return right(convertToEntity);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<ExtracurricularAttendanceDetail>>
  fetchDetailExtracurricularAttendance({required int extraSessionId}) async {
    try {
      final response = await _remoteDataSource.fetchExtraSessionDetail(
        extraSessionId: extraSessionId,
      );

      return right(response.detailExtracurricularAttendance.toEntity());
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<List<ExtracurricularAttendance>>>
  fetchExtracurricularAttendances() async {
    try {
      final response = await _remoteDataSource.fetchAttendances();

      if (response.extracurricularAttendances.isEmpty) {
        return right(<ExtracurricularAttendance>[]);
      }

      return right(
        response.extracurricularAttendances.map((m) => m.toEntity()).toList(),
      );
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
