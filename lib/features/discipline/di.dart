// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:hive_ce/hive_ce.dart';

import '../../core/di/get_it_constant.dart';
import '../../core/internal/src/interfaces/data_interfaces.dart';
import 'data/datasources/local.dart';
import 'data/datasources/remote.dart';
import 'data/repositories/repository_impl.dart';
import 'domain/repositories/repository.dart';
import 'domain/usecases/fetch_demerit_use_case.dart';
import 'domain/usecases/fetch_merit_use_case.dart';
import 'presentation/bloc/demerit_bloc/demerit_bloc.dart';
import 'presentation/bloc/merit_bloc/merit_bloc.dart';

void initDisciplineDI() {
  di.registerLazySingleton<DisciplineLocalDataSource>(
    () => DisciplineLocalDataSourceImpl(di<HiveInterface>()),
  );
  di.registerLazySingleton<DisciplineRemoteDataSource>(
    () => DisciplineRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<DisciplineRepository>(
    () => DisciplineRepositoryImpl(
      di<DisciplineLocalDataSource>(),
      di<DisciplineRemoteDataSource>(),
    ),
  );

  di.registerLazySingleton<FetchMeritUseCase>(
    () => FetchMeritUseCase(di<DisciplineRepository>()),
  );
  di.registerLazySingleton<FetchDemeritUseCase>(
    () => FetchDemeritUseCase(di<DisciplineRepository>()),
  );

  di.registerFactory<DemeritBloc>(() => DemeritBloc(di<FetchDemeritUseCase>()));
  di.registerFactory<MeritBloc>(() => MeritBloc(di<FetchMeritUseCase>()));
}
