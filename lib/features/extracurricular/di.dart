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
import 'domain/usecases/fetch_extracurricular_attendance_detail_use_case.dart';
import 'domain/usecases/fetch_extracurricular_attendances_use_case.dart';
import 'domain/usecases/fetch_extracurricular_use_case.dart';
import 'presentation/bloc/extracurricular_attendance_bloc.dart';
import 'presentation/bloc/extracurricular_bloc.dart';
import 'presentation/cubit/detail_extracurricular_attendance_cubit.dart';

void initExtracurricularDI() {
  di.registerLazySingleton<ExtracurricularLocalDataSource>(
    () => ExtracurricularLocalDataSourceImpl(di<HiveInterface>()),
  );
  di.registerLazySingleton<ExtracurricularRemoteDataSource>(
    () => ExtracurricularRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<ExtracurricularRepository>(
    () => ExtracurricularRepositoryImpl(
      di<ExtracurricularRemoteDataSource>(),
      di<ExtracurricularLocalDataSource>(),
    ),
  );

  di.registerLazySingleton<FetchExtracurricularUseCase>(
    () => FetchExtracurricularUseCase(di<ExtracurricularRepository>()),
  );
  di.registerLazySingleton<FetchExtracurricularAttendancesUseCase>(
    () =>
        FetchExtracurricularAttendancesUseCase(di<ExtracurricularRepository>()),
  );
  di.registerLazySingleton<FetchExtracurricularAttendancesDetailUseCase>(
    () => FetchExtracurricularAttendancesDetailUseCase(
      di<ExtracurricularRepository>(),
    ),
  );

  di.registerFactory<ExtracurricularBloc>(
    () => ExtracurricularBloc(di<FetchExtracurricularUseCase>()),
  );
  di.registerFactory<ExtracurricularAttendanceBloc>(
    () => ExtracurricularAttendanceBloc(
      di<FetchExtracurricularAttendancesUseCase>(),
    ),
  );
  di.registerFactory<DetailExtracurricularAttendanceCubit>(
    () => DetailExtracurricularAttendanceCubit(
      di<FetchExtracurricularAttendancesDetailUseCase>(),
    ),
  );
}
