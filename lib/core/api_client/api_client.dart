// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';

import '../failure/failure.dart';
import '../internal/internal.dart';

part 'api_endpoints.dart';

/// Si paling sibuk yang tugasnya bolak-balik ke server buat urusan data.
///
/// Class ini adalah implementasi nyata dari [HTTPRequest]. Isinya pake Dio
/// buat manggil API, dan udah dilengkapi sama sistem penanganan error otomatis.
class ApiClient implements HTTPRequest {
  /// Bikin instance [ApiClient] baru pake bantuan [_dio].
  ApiClient(this._dio);

  /// Engine utama buat ngirim request HTTP.
  final Dio _dio;

  @override
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      return _parseResponse(response);
    } catch (error, stackTrace) {
      // Kalau gagal, langsung bungkus jadi Failure biar rapi.
      throw Failure.fromError(error, stackTrace);
    }
  }

  @override
  Future<Map<String, dynamic>> post(
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
      throw Failure.fromError(error, stackTrace);
    }
  }

  @override
  Future<Map<String, dynamic>> put(
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
      throw Failure.fromError(error, stackTrace);
    }
  }

  @override
  Future<Unit> delete(String url, {Map<String, dynamic>? data}) async {
    try {
      await _dio.delete(url, data: data);
      return unit;
    } catch (error, stackTrace) {
      throw Failure.fromError(error, stackTrace);
    }
  }

  /// Tukang sortir data biar format yang masuk ke app sesuai ekspektasi.
  ///
  /// Bakal ngecek apakah data dari server beneran [Map] atau malah ngaco.
  /// Throws [Failure.serialization] kalau formatnya nggak sesuai.
  Map<String, dynamic> _parseResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw Failure.serialization(
      errorMessage: 'Format response tidak sesuai ekspektasi.',
      cause: response.data,
    );
  }
}
