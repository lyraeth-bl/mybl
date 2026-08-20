// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/extracurricular_attendance_response/extracurricular_attendance_response.dart';
import '../models/extracurricular_response/extracurricular_response.dart';

abstract class ExtracurricularRemoteDataSource {
  Future<ExtracurricularResponse> fetchAll();

  Future<ExtracurricularAttendanceResponse> fetchAttendances();

  Future<ExtracurricularAttendanceDetailResponse> fetchExtraSessionDetail({
    required int extraSessionId,
  });
}

final class ExtracurricularRemoteDataSourceImpl
    implements ExtracurricularRemoteDataSource {
  ExtracurricularRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<ExtracurricularResponse> fetchAll() async {
    final response = await _httpRequest.get(ApiEndpoints.extracurricular);

    return ExtracurricularResponse.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  @override
  Future<ExtracurricularAttendanceResponse> fetchAttendances() => _httpRequest
      .get(ApiEndpoints.extracurricularAttendances)
      .then(ExtracurricularAttendanceResponse.fromJson);

  @override
  Future<ExtracurricularAttendanceDetailResponse> fetchExtraSessionDetail({
    required int extraSessionId,
  }) => _httpRequest
      .get(ApiEndpoints.extracurricularAttendanceDetail(extraSessionId))
      .then(ExtracurricularAttendanceDetailResponse.fromJson);
}
