// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/auth_response_model/auth_response_model.dart';
import '../models/login_request/login_request.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequest data);

  Future<Unit> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<AuthResponseModel> login(LoginRequest data) async {
    final request = data.toJson();

    final response = await _httpRequest.post(ApiEndpoints.login, data: request);

    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<Unit> logout() async {
    await _httpRequest.post(ApiEndpoints.logout, data: {});

    return unit;
  }
}
