// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Keys whose values must never reach the log.
///
/// Longer names come first so the alternation matches `access_token` before
/// `token`. The `\b` boundaries keep `token_type` from matching `token`.
final RegExp _sensitiveValuePattern = RegExp(
  r'("?\b(?:password_confirmation|password|access_token|reset_token|'
  r'refresh_token|otp_code|authorization|token)\b"?\s*:\s*)'
  r'("[^"]*"|[^,}\s][^,}]*)',
  caseSensitive: false,
);

/// Masks credential values while leaving the rest of the log line intact.
///
/// Matches all three shapes [PrettyDioLogger] emits: JSON (`"password": "x"`),
/// header/body pairs (`password: x`), and map `toString` (`{password: x}`).
/// Status codes, timings, and non-sensitive fields stay readable — losing them
/// entirely would hide real response bugs.
String _redactSensitiveValues(Object object) => object
    .toString()
    .replaceAllMapped(_sensitiveValuePattern, (match) => '${match[1]}***');

class DioFactory {
  Dio buildDioClient({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 20),
    List<Interceptor> extraInterceptors = const [],
    bool enablePrettyLogging = false,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
      ),
    );

    if (enablePrettyLogging) {
      dio.interceptors.add(_prettyLogger());
    }

    dio.interceptors.addAll([...extraInterceptors]);

    return dio;
  }

  Interceptor _prettyLogger() => PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    compact: true,
    maxWidth: 90,
    logPrint: (object) => debugPrint(_redactSensitiveValues(object)),
  );
}
