// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/auth_response_model/auth_response_model.dart';
import '../models/login_request/login_request.dart';

/// Si paling tau endpoint API mana yang harus dipanggil buat urusan Auth.
///
/// Class ini fokus buat ngobrol langsung sama server. Nggak pake mikir logic
/// bisnis, pokoknya request dan lempar hasil (atau error).
abstract class AuthRemoteDataSource {
  /// Manggil API login pake [data] request.
  Future<AuthResponseModel> login(LoginRequest data);

  /// Manggil API logout buat beresin sesi di server.
  Future<Unit> logout();
}

/// Implementasi nyata dari [AuthRemoteDataSource] pake [HTTPRequest].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Bikin instance bareng [_httpRequest] buat senjata utama manggil API.
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
