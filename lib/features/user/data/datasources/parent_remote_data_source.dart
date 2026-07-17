// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/parent_response/parent_response.dart';

abstract class ParentRemoteDataSource {
  Future<ParentResponse> fetch();
}

class ParentRemoteDataSourceImpl implements ParentRemoteDataSource {
  ParentRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<ParentResponse> fetch() async => _httpRequest
      .get(ApiEndpoints.parentMe)
      .then(
        (response) =>
            ParentResponse.fromJson(Map<String, dynamic>.from(response)),
      );
}
