// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/academic_result_model/academic_result_model.dart';

abstract class AcademicResultRemoteDataSource {
  Future<AcademicResultResponseModel> fetch();
}

class AcademicResultRemoteDataSourceImpl
    implements AcademicResultRemoteDataSource {
  AcademicResultRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<AcademicResultResponseModel> fetch() async {
    final response = await _httpRequest.get(ApiEndpoints.result);

    return AcademicResultResponseModel.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}
