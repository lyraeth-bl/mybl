// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_bl/core/api_client/api_client.dart';

import '../di/get_it_constant.dart';
import 'dio_factory.dart';

void _initNetworkDI({
  required String baseUrl,
  Future<String?> Function()? tokenProvider,
  Future<void> Function()? onUnauthorized,
}) async {
  final dio = DioFactory().buildDioClient(
    baseUrl: baseUrl,
    enablePrettyLogging: !kReleaseMode,
    extraInterceptors: [
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenProvider?.call();
          debugPrint("TOKEN USED: $token");

          if (token != null && token.isNotEmpty) {
            options.headers['Accept'] = "application/json";
            options.headers['Content-Type'] = "application/json";
            options.headers['Authorization'] = "Bearer $token";
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await onUnauthorized?.call();
          }

          handler.next(error);
        },
      ),
    ],
  );

  di.registerLazySingleton<Dio>(() => dio);
}

void initNetworkDI() => _initNetworkDI(baseUrl: ApiEndpoints.baseUrl);
