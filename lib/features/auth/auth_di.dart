// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:hive_ce/hive_ce.dart';

import '../../core/di/get_it_constant.dart';
import '../../core/internal/src/interfaces/data_interfaces.dart';
import 'data/datasources/auth_local_data_source.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_use_case.dart';
import 'domain/usecases/logout_use_case.dart';
import 'presentation/bloc/auth_bloc.dart';

void initAuthDI() {
  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      di<AuthRemoteDataSource>(),
      di<AuthLocalDataSource>(),
    ),
  );

  di.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(di<HTTPRequest>()),
  );
  di.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(di<HiveInterface>()),
  );

  di.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(di<AuthRepository>()),
  );
  di.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(di<AuthRepository>()),
  );

  di.registerFactory<AuthBloc>(
    () => AuthBloc(di<LoginUseCase>(), di<LogoutUseCase>()),
  );
}
