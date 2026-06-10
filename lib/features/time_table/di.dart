// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:hive_ce/hive_ce.dart';

import '../../core/di/get_it_constant.dart';
import '../../core/internal/src/interfaces/data_interfaces.dart';
import '../user/presentation/bloc/user_bloc.dart';
import 'data/datasources/local.dart';
import 'data/datasources/remote.dart';
import 'data/repositories/repository_impl.dart';
import 'domain/repositories/repository.dart';
import 'domain/usecases/fetch_time_table_use_case.dart';
import 'presentation/bloc/time_table_bloc.dart';

void initTimeTableDI() {
  di.registerLazySingleton<TimeTableRemoteDataSource>(
    () => TimeTableRemoteDataSourceImpl(di<HTTPRequest>()),
  );
  di.registerLazySingleton<TimeTableLocalDataSource>(
    () => TimeTableLocalDataSourceImpl(di<HiveInterface>()),
  );

  di.registerLazySingleton<TimeTableRepository>(
    () => TimeTableRepositoryImpl(
      di<TimeTableRemoteDataSource>(),
      di<TimeTableLocalDataSource>(),
    ),
  );

  di.registerLazySingleton<FetchTimeTableUseCase>(
    () => FetchTimeTableUseCase(di<TimeTableRepository>()),
  );

  di.registerFactory<TimeTableBloc>(
    () => TimeTableBloc(di<FetchTimeTableUseCase>(), di<UserBloc>()),
  );
}
