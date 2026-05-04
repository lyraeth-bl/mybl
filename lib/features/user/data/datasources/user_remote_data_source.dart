// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/student_response/student_response.dart';

abstract class UserRemoteDataSource {
  Future<StudentResponse> fetch();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<StudentResponse> fetch() async {
    final response = await _httpRequest.get(ApiEndpoints.me);

    return StudentResponse.fromJson(response);
  }
}
