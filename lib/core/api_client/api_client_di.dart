// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:dio/dio.dart';

import '../di/get_it_constant.dart';
import '../internal/src/interfaces/data_interfaces.dart';
import 'api_client.dart';

void initApiClientDI() {
  di.registerLazySingleton<HTTPRequest>(() => ApiClient(di<Dio>()));
}
