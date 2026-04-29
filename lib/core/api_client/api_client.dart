// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:my_bl/core/dio_factory/network_di.dart';

import '../failure/failure.dart';
import '../internal/internal.dart';

part 'api_endpoints.dart';

class ApiClient implements HTTPRequest {
  ApiClient(this._dio);

  final Dio _dio;

  @override
  Future<HTTPResult> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      return _parseResponse(response);
    } catch (error, stackTrace) {
      return left(Failure.fromDio(error, stackTrace));
    }
  }

  @override
  Future<HTTPResult> post(
    String url, {
    Map<String, dynamic>? queryParameters,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        url,
        queryParameters: queryParameters,
        data: data,
      );
      return _parseResponse(response);
    } catch (error, stackTrace) {
      return left(Failure.fromDio(error, stackTrace));
    }
  }

  @override
  Future<HTTPResult> put(
    String url, {
    Map<String, dynamic>? queryParameters,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.put(
        url,
        queryParameters: queryParameters,
        data: data,
      );
      return _parseResponse(response);
    } catch (error, stackTrace) {
      return left(Failure.fromDio(error, stackTrace));
    }
  }

  @override
  Future<Unit> delete(String url) async {
    try {
      await _dio.delete(url);
      return unit;
    } catch (error) {
      return unit;
    }
  }

  HTTPResult _parseResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return right(data);
    return left(
      Failure.serialization(
        errorMessage: 'Format response tidak sesuai ekspektasi.',
        cause: response.data,
      ),
    );
  }
}
