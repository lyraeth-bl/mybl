// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../core/di/get_it_constant.dart';
import '../../core/internal/src/interfaces/data_interfaces.dart';
import 'data/datasources/remote.dart';
import 'data/repositories/repository_impl.dart';
import 'domain/repositories/repository.dart';
import 'domain/usecases/fetch_academic_result_use_case.dart';
import 'presentation/bloc/academic_result_bloc.dart';

void initAcademicResultDI() {
  di.registerLazySingleton<AcademicResultRemoteDataSource>(
    () => AcademicResultRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<AcademicResultRepository>(
    () => AcademicResultRepositoryImpl(di<AcademicResultRemoteDataSource>()),
  );

  di.registerLazySingleton<FetchAcademicResultUseCase>(
    () => FetchAcademicResultUseCase(di<AcademicResultRepository>()),
  );

  di.registerFactory<AcademicResultBloc>(
    () => AcademicResultBloc(di<FetchAcademicResultUseCase>()),
  );
}
