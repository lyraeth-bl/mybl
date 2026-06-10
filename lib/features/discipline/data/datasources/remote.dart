// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/discipline_model/discipline_response/discipline_response.dart';

abstract class DisciplineRemoteDataSource {
  Future<MeritResponse> fetchMerit({String? schoolSession, String? semester});

  Future<DemeritResponse> fetchDemerit({
    String? schoolSession,
    String? semester,
  });
}

class DisciplineRemoteDataSourceImpl implements DisciplineRemoteDataSource {
  DisciplineRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<DemeritResponse> fetchDemerit({
    String? schoolSession,
    String? semester,
  }) async {
    final response = await _httpRequest.get(
      ApiEndpoints.demerit,
      queryParameters: {
        if ((schoolSession ?? '').isNotEmpty) "Tajaran": schoolSession,
        if ((semester ?? '').isNotEmpty) "Semester": semester,
      },
    );

    return DemeritResponse.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<MeritResponse> fetchMerit({
    String? schoolSession,
    String? semester,
  }) async {
    final response = await _httpRequest.get(
      ApiEndpoints.merit,
      queryParameters: {
        if ((schoolSession ?? '').isNotEmpty) "Tajaran": schoolSession,
        if ((semester ?? '').isNotEmpty) "Semester": semester,
      },
    );

    return MeritResponse.fromJson(Map<String, dynamic>.from(response));
  }
}
