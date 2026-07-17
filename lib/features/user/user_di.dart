// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:hive_ce/hive_ce.dart';

import '../../core/di/get_it_constant.dart';
import '../../core/internal/src/interfaces/data_interfaces.dart';
import 'data/datasources/parent_local_data_source.dart';
import 'data/datasources/parent_remote_data_source.dart';
import 'data/datasources/user_local_data_source.dart';
import 'data/datasources/user_remote_data_source.dart';
import 'data/repositories/parent_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/parent_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/usecases/fetch_parent_use_case.dart';
import 'domain/usecases/fetch_student_use_case.dart';
import 'domain/usecases/read_children_use_case.dart';
import 'domain/usecases/read_selected_child_use_case.dart';
import 'domain/usecases/save_children_use_case.dart';
import 'domain/usecases/save_selected_child_use_case.dart';
import 'presentation/bloc/parent_bloc/parent_bloc.dart';
import 'presentation/bloc/user_bloc.dart';

void initUserDI() {
  di.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      di<UserLocalDataSource>(),
      di<UserRemoteDataSource>(),
    ),
  );

  di.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(di<HiveInterface>()),
  );

  di.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<FetchStudentUseCase>(
    () => FetchStudentUseCase(di<UserRepository>()),
  );

  di.registerLazySingleton<UserBloc>(() => UserBloc(di<FetchStudentUseCase>()));

  // --- Parent --- //

  di.registerLazySingleton<ParentRepository>(
    () => ParentRepositoryImpl(
      di<ParentLocalDataSource>(),
      di<ParentRemoteDataSource>(),
    ),
  );

  di.registerLazySingleton<ParentLocalDataSource>(
    () => ParentLocalDataSourceImpl(di<HiveInterface>()),
  );

  di.registerLazySingleton<ParentRemoteDataSource>(
    () => ParentRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<FetchParentUseCase>(
    () => FetchParentUseCase(di<ParentRepository>()),
  );

  di.registerLazySingleton<SaveChildrenUseCase>(
    () => SaveChildrenUseCase(di<ParentRepository>()),
  );

  di.registerLazySingleton<ReadChildrenUseCase>(
    () => ReadChildrenUseCase(di<ParentRepository>()),
  );

  di.registerLazySingleton<SaveSelectedChildUseCase>(
    () => SaveSelectedChildUseCase(di<ParentRepository>()),
  );

  di.registerLazySingleton<ReadSelectedChildUseCase>(
    () => ReadSelectedChildUseCase(di<ParentRepository>()),
  );

  di.registerLazySingleton<ParentBloc>(
    () => ParentBloc(
      di<FetchParentUseCase>(),
      di<SaveChildrenUseCase>(),
      di<ReadChildrenUseCase>(),
      di<SaveSelectedChildUseCase>(),
      di<ReadSelectedChildUseCase>(),
    ),
  );
}
