// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/sarpras/sarpras.dart';
import '../../domain/entities/sarpras_params/sarpras_params.dart';
import '../../domain/entities/sarpras_summary/sarpras_summary.dart';
import '../../domain/entities/sarpras_teacher_candidate/sarpras_teacher_candidate.dart';
import '../../domain/repositories/sarpras_repository.dart';
import '../datasources/sarpras_remote_data_source.dart';
import '../models/sarpras_detail_response/sarpras_detail_response.dart';
import '../models/sarpras_model/sarpras_model.dart';
import '../models/sarpras_request/sarpras_request.dart';
import '../models/sarpras_teacher_candidate_model/sarpras_teacher_candidate_model.dart';

final class SarprasRepositoryImpl implements SarprasRepository {
  SarprasRepositoryImpl(this._remoteDataSource);

  final SarprasRemoteDataSource _remoteDataSource;

  Result<Sarpras> _unwrap(SarprasDetailResponse response) {
    final sarpras = response.sarpras;

    if (sarpras == null) {
      return left(Failure.unexpected(errorMessage: response.message));
    }

    return right(sarpras.toEntity());
  }

  @override
  Future<Result<Unit>> destroySarpras({required int sarprasId}) async {
    try {
      await _remoteDataSource.destroySarpras(sarprasId: sarprasId);

      return right(unit);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<Sarpras>> fetchDetailSarpras({required int sarprasId}) async {
    try {
      final response = await _remoteDataSource.fetchDetailSarpras(
        sarprasId: sarprasId,
      );

      return _unwrap(response);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<(SarprasSummary, List<Sarpras>)>> fetchSarpras() async {
    try {
      final response = await _remoteDataSource.fetchSarpras();

      return right((
        response.summary.toEntity(),
        response.listSarpras.map((m) => m.toEntity()).toList(),
      ));
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<List<SarprasTeacherCandidate>>>
  fetchSarprasTeacherCandidate() async {
    try {
      final response = await _remoteDataSource.fetchSarprasTeacherCandidate();

      return right(response.listTeacher.map((m) => m.toEntity()).toList());
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<Sarpras>> storeSarpras(SarprasParams params) async {
    try {
      final response = await _remoteDataSource.storeSarpras(params.toRequest());

      return _unwrap(response);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<Sarpras>> updateSarpras({
    required int sarprasId,
    required SarprasParams params,
  }) async {
    try {
      final response = await _remoteDataSource.updateSarpras(
        sarprasId: sarprasId,
        request: params.toRequest(),
      );

      return _unwrap(response);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
