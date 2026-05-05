// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/app_configuration_response/app_configuration_response.dart';

/// Tukang gali data (Data Source) yang fokus ambil config dari internet.
///
/// Tugas utamanya cuma satu: konek ke API lewat [_httpRequest] dan
/// balikin data mentah dalam bentuk [AppConfigurationResponse].
abstract class AppConfigurationRemoteDataSource {
  /// Ambil data config paling fresh dari server.
  Future<AppConfigurationResponse> fetch();
}

/// Implementasi nyata dari [AppConfigurationRemoteDataSource].
class AppConfigurationRemoteDataSourceImpl
    implements AppConfigurationRemoteDataSource {
  /// Butuh [_httpRequest] biar bisa ngobrol sama server.
  AppConfigurationRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<AppConfigurationResponse> fetch() async {
    final response = await _httpRequest.get(ApiEndpoints.appConfig);

    return AppConfigurationResponse.fromJson(response);
  }
}
