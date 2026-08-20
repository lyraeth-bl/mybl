// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/sessions/presentation/bloc/session_bloc.dart';
import '../../features/user/presentation/bloc/parent_bloc/parent_bloc.dart';
import '../api_client/api_client.dart';
import '../di/get_it_constant.dart';
import '../enums/user_role.dart';
import '../token_provider/parent_token_provider.dart';
import '../token_provider/token_provider.dart';
import 'dio_factory.dart';
import 'interceptors/student_nis_interceptor.dart';

void _initNetworkDI({
  required String baseUrl,
  Future<String?> Function()? tokenProvider,
  Future<void> Function()? onUnauthorized,
  List<Interceptor> extraInterceptors = const [],
}) async {
  final dio = DioFactory().buildDioClient(
    baseUrl: baseUrl,
    enablePrettyLogging: kDebugMode,
    extraInterceptors: [
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenProvider?.call();

          options.headers['Accept'] = "application/json";
          options.headers['Content-Type'] = "application/json";

          if (token != null && token.isNotEmpty) {
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
      ...extraInterceptors,
    ],
  );

  di.registerLazySingleton<Dio>(() => dio);
}

void initNetworkDI() => _initNetworkDI(
  baseUrl: ApiEndpoints.baseUrl,
  tokenProvider: () {
    final sessionState = di<SessionBloc>().state;
    final isAuthenticated = sessionState.maybeWhen(
      authenticated: (_, _) => true,
      orElse: () => false,
    );
    final isParent = sessionState.maybeWhen(
      authenticated: (_, role) => role == UserRole.parent,
      orElse: () => false,
    );

    if (isAuthenticated && isParent) {
      return di<ParentTokenProvider>().readParentAccessToken();
    }

    return di<TokenProvider>().readAccessToken();
  },
  onUnauthorized: () async {
    final sessionState = di<SessionBloc>().state;
    final isAuthenticated = sessionState.maybeWhen(
      authenticated: (_, _) => true,
      orElse: () => false,
    );
    final isParent = sessionState.maybeWhen(
      authenticated: (_, role) => role == UserRole.parent,
      orElse: () => false,
    );

    if (isAuthenticated && isParent) {
      di<ParentTokenProvider>().clearParentAccessToken();
    } else {
      di<TokenProvider>().clearAccessToken();
    }
    di<SessionBloc>().add(const SessionEvent.loggedOut());
  },
  extraInterceptors: [
    StudentNisInterceptor(
      parentBloc: () => di<ParentBloc>(),
      getRoleCallback: () => di<SessionBloc>().state.maybeWhen(
        authenticated: (_, role) => role,
        orElse: () => UserRole.student,
      ),
    ),
  ],
);
