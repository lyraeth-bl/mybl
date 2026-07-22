// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/sarpras_detail_response/sarpras_detail_response.dart';
import '../models/sarpras_request/sarpras_request.dart';
import '../models/sarpras_response/sarpras_response.dart';
import '../models/sarpras_teacher_candidate_response/sarpras_teacher_candidate_response.dart';

abstract class SarprasRemoteDataSource {
  Future<SarprasResponse> fetchSarpras();

  Future<SarprasDetailResponse> fetchDetailSarpras({required int sarprasId});

  Future<SarprasDetailResponse> storeSarpras(SarprasRequest request);

  Future<SarprasDetailResponse> updateSarpras({
    required int sarprasId,
    required SarprasRequest request,
  });

  Future<Unit> destroySarpras({required int sarprasId});

  Future<SarprasTeacherCandidateResponse> fetchSarprasTeacherCandidate();
}

final class SarprasRemoteDataSourceImpl implements SarprasRemoteDataSource {
  SarprasRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<Unit> destroySarpras({required int sarprasId}) =>
      _httpRequest.delete(ApiEndpoints.sarpras(sarprasId)).then((_) => unit);

  @override
  Future<SarprasDetailResponse> fetchDetailSarpras({required int sarprasId}) =>
      _httpRequest
          .get(ApiEndpoints.sarpras(sarprasId))
          .then(SarprasDetailResponse.fromJson);

  @override
  Future<SarprasResponse> fetchSarpras() =>
      _httpRequest.get(ApiEndpoints.listSarpras).then(SarprasResponse.fromJson);

  @override
  Future<SarprasTeacherCandidateResponse> fetchSarprasTeacherCandidate() =>
      _httpRequest
          .get(ApiEndpoints.sarprasGuruPendamping)
          .then(SarprasTeacherCandidateResponse.fromJson);

  @override
  Future<SarprasDetailResponse> storeSarpras(SarprasRequest request) =>
      _httpRequest
          .post(ApiEndpoints.listSarpras, data: request.toJson())
          .then(SarprasDetailResponse.fromJson);

  @override
  Future<SarprasDetailResponse> updateSarpras({
    required int sarprasId,
    required SarprasRequest request,
  }) => _httpRequest
      .put(ApiEndpoints.sarpras(sarprasId), data: request.toJson())
      .then(SarprasDetailResponse.fromJson);
}
