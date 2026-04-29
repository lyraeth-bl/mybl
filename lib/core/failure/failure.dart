import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const Failure._();

  const factory Failure.network({
    String? errorMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Network;

  const factory Failure.server({
    String? errorMessage,
    int? statusCode,
    String? code,
    Map<String, dynamic>? data,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Server;

  const factory Failure.unauthorized({
    String? errorMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Unauthorized;

  const factory Failure.forbidden({
    String? errorMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Forbidden;

  const factory Failure.badRequest({
    String? errorMessage,
    Map<String, dynamic>? fieldErrors,
    Object? cause,
    StackTrace? stackTrace,
  }) = _BadRequest;

  const factory Failure.serialization({
    String? errorMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Serialization;

  const factory Failure.cancelled({
    String? errorMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Cancelled;

  const factory Failure.rateLimited({
    String? errorMessage,
    Duration? retryAfter,
    Object? cause,
    StackTrace? stackTrace,
  }) = _RateLimited;

  const factory Failure.timeout({
    String? errorMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Timeout;

  const factory Failure.unexpected({
    String? errorMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _Unexpected;

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

  static Failure fromDio(Object error, [StackTrace? stackTrace]) {
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
            errorMessage: 'Bad certificate',
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

  static String? _extractString(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = map[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }
}
