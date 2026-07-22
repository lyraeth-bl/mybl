// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../core/di/get_it_constant.dart';
import '../../core/internal/src/interfaces/data_interfaces.dart';
import 'data/datasources/sarpras_remote_data_source.dart';
import 'data/repositories/sarpras_repository_impl.dart';
import 'domain/repositories/sarpras_repository.dart';
import 'domain/usecases/destroy_sarpras_use_case.dart';
import 'domain/usecases/fetch_detail_sarpras_use_case.dart';
import 'domain/usecases/fetch_sarpras_teacher_candidate_use_case.dart';
import 'domain/usecases/fetch_sarpras_use_case.dart';
import 'domain/usecases/store_sarpras_use_case.dart';
import 'domain/usecases/update_sarpras_use_case.dart';
import 'presentation/bloc/sarpras_bloc.dart';
import 'presentation/cubit/destroy_sarpras_cubit.dart';
import 'presentation/cubit/store_sarpras_cubit.dart';
import 'presentation/cubit/update_sarpras_cubit.dart';

void initSarprasDI() {
  di.registerLazySingleton<SarprasRemoteDataSource>(
    () => SarprasRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<SarprasRepository>(
    () => SarprasRepositoryImpl(di<SarprasRemoteDataSource>()),
  );

  di.registerLazySingleton<FetchSarprasUseCase>(
    () => FetchSarprasUseCase(di<SarprasRepository>()),
  );
  di.registerLazySingleton<FetchSarprasTeacherCandidateUseCase>(
    () => FetchSarprasTeacherCandidateUseCase(di<SarprasRepository>()),
  );
  di.registerLazySingleton<FetchDetailSarprasUseCase>(
    () => FetchDetailSarprasUseCase(di<SarprasRepository>()),
  );
  di.registerLazySingleton<StoreSarprasUseCase>(
    () => StoreSarprasUseCase(di<SarprasRepository>()),
  );
  di.registerLazySingleton<UpdateSarprasUseCase>(
    () => UpdateSarprasUseCase(di<SarprasRepository>()),
  );
  di.registerLazySingleton<DestroySarprasUseCase>(
    () => DestroySarprasUseCase(di<SarprasRepository>()),
  );

  di.registerFactory<SarprasBloc>(() => SarprasBloc(di<FetchSarprasUseCase>()));
  di.registerFactory<StoreSarprasCubit>(
    () => StoreSarprasCubit(di<StoreSarprasUseCase>()),
  );
  di.registerFactory<DestroySarprasCubit>(
    () => DestroySarprasCubit(di<DestroySarprasUseCase>()),
  );
  di.registerFactory<UpdateSarprasCubit>(
    () => UpdateSarprasCubit(di<UpdateSarprasUseCase>()),
  );
}
