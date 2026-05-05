// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/app_configuration_response/app_configuration_response.dart';

abstract class AppConfigurationRemoteDataSource {
  Future<AppConfigurationResponse> fetch();
}

class AppConfigurationRemoteDataSourceImpl
    implements AppConfigurationRemoteDataSource {
  AppConfigurationRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<AppConfigurationResponse> fetch() async {
    final response = await _httpRequest.get(ApiEndpoints.appConfig);

    return AppConfigurationResponse.fromJson(response);
  }
}
