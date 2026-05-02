// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../l10n/app_localizations.dart';

part 'failure.freezed.dart';

/// Class buat nampung semua masalah (error) yang mungkin kejadian di app.
///
/// Daripada app-nya crash atau bengong pas ada error, kita bungkus semuanya
/// di sini biar kita bisa kasih tau user apa yang sebenernya terjadi secara rapi.
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  /// Pas internet lagi ampas atau mati total.
  const factory Failure.network({
    /// Pesan error yang bisa dibaca manusia.
    String? errorMessage,

    /// Objek error aslinya kalau mau di-debug.
    Object? cause,

    /// Jejak error-nya di mana.
    StackTrace? stackTrace,
  }) = _Network;

  /// Pas server-nya lagi tantrum atau nge-drop error 500-an.
  const factory Failure.server({
    /// Pesan error dari server.
    String? errorMessage,

    /// Kode status HTTP-nya (misal 500, 503).
    int? statusCode,

    /// Kode error spesifik dari API (kalau ada).
    String? code,

    /// Data tambahan dari server biar kita tau salahnya di mana.
    Map<String, dynamic>? data,

    /// Error aslinya.
    Object? cause,

    /// Stack trace buat debugging.
    StackTrace? stackTrace,
  }) = _Server;

  /// Pas user lupa login atau session-nya udah expired.
  const factory Failure.unauthorized({
    String? errorMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Unauthorized;

  /// Pas user nyoba akses fitur yang bukan jatahnya (Forbidden).
  const factory Failure.forbidden({
    String? errorMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Forbidden;

  /// Pas input dari user ada yang ngaco atau nggak valid.
  const factory Failure.badRequest({
    /// Pesan error umum.
    String? errorMessage,

    /// List error per field (misal: email nggak valid).
    Map<String, dynamic>? fieldErrors,
    Object? cause,
    StackTrace? stackTrace,
  }) = _BadRequest;

  /// Pas kita gagal ngebaca data dari server (Gagal JSON parsing).
  const factory Failure.serialization({
    String? errorMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Serialization;

  /// Pas request-nya dibatalin sama kita sendiri (misal user pindah halaman).
  const factory Failure.cancelled({
    String? errorMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Cancelled;

  /// Pas user nge-spam request kenceng banget sampai kena limit.
  const factory Failure.rateLimited({
    String? errorMessage,

    /// Info kapan kita bisa coba lagi.
    Duration? retryAfter,
    Object? cause,
    StackTrace? stackTrace,
  }) = _RateLimited;

  /// Pas server kelamaan ngejawab (Timeout).
  const factory Failure.timeout({
    String? errorMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Timeout;

  /// Buat error yang aneh-aneh dan nggak masuk kategori di atas.
  const factory Failure.unexpected({
    String? errorMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Unexpected;

  /// Ngambil key buat translate error-nya.
  String get messageKey => map(
    network: (_) => 'dioNetworkError',
    server: (_) => 'dioServerError',
    unauthorized: (_) => 'dioUnauthorizedError',
    forbidden: (_) => 'dioForbiddenError',
    badRequest: (_) => 'dioBadRequestError',
    serialization: (_) => 'dioSerializationError',
    cancelled: (_) => 'dioCancelledError',
    rateLimited: (_) => 'dioRateLimitedError',
    timeout: (_) => 'dioTimeoutError',
    unexpected: (_) => 'dioUnexpectedError',
  );

  /// Label singkat buat tipe error-nya.
  String get labelError => map(
    network: (_) => 'network',
    server: (_) => 'server',
    unauthorized: (_) => 'unauthorized',
    forbidden: (_) => 'forbidden',
    badRequest: (_) => 'badRequest',
    serialization: (_) => 'serialization',
    cancelled: (_) => 'cancelled',
    rateLimited: (_) => 'rateLimited',
    timeout: (_) => 'timeout',
    unexpected: (_) => 'unexpected',
  );

  /// Ubah error jadi pesan yang bisa dibaca user sesuai bahasa yang dipilih.
  ///
  /// Butuh [l10n] buat nyari teks yang pas di file ARB.
  ///
  /// Contoh cara pakainya di UI:
  /// ```dart
  /// final l10n = AppLocalizations.of(context);
  /// final text = failure.localizedMessage(l10n);
  /// ```
  String localizedMessage(AppLocalizations l10n) => map(
    network: (_) => l10n.dioNetworkError,
    server: (_) => l10n.dioServerError,
    unauthorized: (_) => l10n.dioUnauthorizedError,
    forbidden: (_) => l10n.dioForbiddenError,
    badRequest: (_) => l10n.dioBadRequestError,
    serialization: (_) => l10n.dioSerializationError,
    cancelled: (_) => l10n.dioCancelledError,
    rateLimited: (_) => l10n.dioRateLimitedError,
    timeout: (_) => l10n.dioTimeoutError,
    unexpected: (_) => l10n.dioUnexpectedError,
  );

  /// Fungsi sakti buat ngerubah error apapun (Dio, Socket, dll) jadi [Failure].
  ///
  /// Masukin [error] aslinya dan opsional [stackTrace]-nya.
  /// Returns salah satu jenis [Failure] yang paling pas.
  static Failure fromError(Object error, [StackTrace? stackTrace]) {
    if (error is DioException) {
      final e = error;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Failure.timeout(
            cause: e,
            stackTrace: stackTrace ?? e.stackTrace,
          );
        case DioExceptionType.badCertificate:
          return Failure.network(
            errorMessage: 'Sertifikat SSL/TLS bermasalah.',
            cause: e,
            stackTrace: stackTrace ?? e.stackTrace,
          );
        case DioExceptionType.cancel:
          return Failure.cancelled(
            cause: e,
            stackTrace: stackTrace ?? e.stackTrace,
          );
        case DioExceptionType.connectionError:
          return _mapConnectionError(e, stackTrace);
        case DioExceptionType.badResponse:
          return _mapBadResponse(e, stackTrace);
        case DioExceptionType.unknown:
          final underlying = e.error;
          if (underlying is SocketException) {
            return Failure.network(
              cause: e,
              stackTrace: stackTrace ?? e.stackTrace,
            );
          }
          if (underlying is HandshakeException || underlying is TlsException) {
            return Failure.network(
              errorMessage: 'Error handshake TLS.',
              cause: e,
              stackTrace: stackTrace ?? e.stackTrace,
            );
          }
          return Failure.unexpected(
            cause: e,
            stackTrace: stackTrace ?? e.stackTrace,
          );
      }
    }

    if (error is FormatException || error is TypeError) {
      return Failure.serialization(cause: error, stackTrace: stackTrace);
    }
    if (error is SocketException) {
      return Failure.network(cause: error, stackTrace: stackTrace);
    }
    return Failure.unexpected(cause: error, stackTrace: stackTrace);
  }

  /// Private helper buat nge-map error koneksi.
  static Failure _mapConnectionError(
    DioException error,
    StackTrace? stackTrace,
  ) {
    final underlying = error.error;
    if (underlying is SocketException) {
      return Failure.network(
        cause: error,
        stackTrace: stackTrace ?? error.stackTrace,
      );
    }
    if (underlying is HandshakeException || underlying is TlsException) {
      return Failure.network(
        errorMessage: 'Error handshake TLS.',
        cause: error,
        stackTrace: stackTrace ?? error.stackTrace,
      );
    }
    return Failure.network(
      cause: error,
      stackTrace: stackTrace ?? error.stackTrace,
    );
  }

  /// Private helper buat nge-bedain error berdasarkan status code HTTP.
  static Failure _mapBadResponse(DioException e, StackTrace? st) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    String? message;
    String? apiCode;
    Map<String, dynamic>? payload;

    if (data is Map<String, dynamic>) {
      payload = data;
      message = data['message'] as String?;
      apiCode = _extractString(data, ['code', 'error_code', 'errorCode']);
    }

    switch (status) {
      case 400:
      case 422:
        return Failure.badRequest(
          errorMessage: message,
          fieldErrors: payload?['errors'] is Map<String, dynamic>
              ? payload!['errors']
              : null,
          cause: e,
          stackTrace: st ?? e.stackTrace,
        );

      case 401:
        return Failure.unauthorized(
          errorMessage: message,
          cause: e,
          stackTrace: st ?? e.stackTrace,
        );

      case 403:
        return Failure.forbidden(
          errorMessage: message,
          cause: e,
          stackTrace: st ?? e.stackTrace,
        );

      case 409:
        return Failure.server(
          errorMessage: message,
          statusCode: status,
          code: apiCode,
          data: payload,
          cause: e,
          stackTrace: st ?? e.stackTrace,
        );

      default:
        if (status != null && status >= 500) {
          return Failure.server(
            errorMessage: message,
            statusCode: status,
            code: apiCode,
            data: payload,
            cause: e,
            stackTrace: st ?? e.stackTrace,
          );
        }

        return Failure.unexpected(
          errorMessage: message,
          cause: e,
          stackTrace: st ?? e.stackTrace,
        );
    }
  }

  /// Nyari String di dalam [map] berdasarkan list [keys] yang dikasih.
  static String? _extractString(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = map[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }
}
