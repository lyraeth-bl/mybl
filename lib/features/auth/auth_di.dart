// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:hive_ce/hive_ce.dart';

import '../../core/di/get_it_constant.dart';
import '../../core/internal/src/interfaces/data_interfaces.dart';
import 'data/datasources/auth_local_data_source.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/parent_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/parent_auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/parent_auth_repository.dart';
import 'domain/usecases/login_parent_use_case.dart';
import 'domain/usecases/login_use_case.dart';
import 'domain/usecases/logout_use_case.dart';
import 'domain/usecases/read_nis_use_case.dart';
import 'domain/usecases/save_nis_use_case.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/remember_me/remember_me_cubit.dart';

void initAuthDI() {
  di.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(di<HiveInterface>()),
  );
  di.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(di<HTTPRequest>()),
  );
  di.registerLazySingleton<ParentRemoteDataSource>(
    () => ParentRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      di<AuthRemoteDataSource>(),
      di<AuthLocalDataSource>(),
    ),
  );
  di.registerLazySingleton<ParentAuthRepository>(
    () => ParentAuthRepositoryImpl(
      di<ParentRemoteDataSource>(),
      di<AuthLocalDataSource>(),
    ),
  );

  di.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(di<AuthRepository>()),
  );
  di.registerLazySingleton<LoginParentUseCase>(
    () => LoginParentUseCase(di<ParentAuthRepository>()),
  );
  di.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(di<AuthRepository>()),
  );
  di.registerLazySingleton<ReadNisUseCase>(
    () => ReadNisUseCase(di<AuthRepository>()),
  );
  di.registerLazySingleton<SaveNisUseCase>(
    () => SaveNisUseCase(di<AuthRepository>()),
  );

  di.registerFactory<AuthBloc>(
    () => AuthBloc(
      di<LoginUseCase>(),
      di<LogoutUseCase>(),
      di<LoginParentUseCase>(),
    ),
  );
  di.registerFactory<RememberMeCubit>(
    () => RememberMeCubit(di<ReadNisUseCase>(), di<SaveNisUseCase>()),
  );
}
