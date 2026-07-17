// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/academic_result/academic_result.dart';
import '../../domain/repositories/repository.dart';
import '../datasources/remote.dart';
import '../models/academic_result_model/academic_result_model.dart';

class AcademicResultRepositoryImpl implements AcademicResultRepository {
  AcademicResultRepositoryImpl(this._remoteDataSource);

  final AcademicResultRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AcademicResultResponse>> fetch({
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _remoteDataSource.fetch();

      return right(response.toEntity());
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
