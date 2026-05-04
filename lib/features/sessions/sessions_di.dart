// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/di/get_it_constant.dart';
import '../../core/storage/domain/usecases/clear_all_boxes_use_case.dart';
import 'data/datasources/session_local_data_source.dart';
import 'data/repositories/session_repository_impl.dart';
import 'domain/repositories/session_repository.dart';
import 'domain/usecases/clear_access_token_use_case.dart';
import 'domain/usecases/read_access_token_use_case.dart';
import 'domain/usecases/save_access_token_use_case.dart';
import 'presentation/bloc/session_bloc.dart';

void initSessionsDI() {
  di.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(di<SessionLocalDataSource>()),
  );

  di.registerLazySingleton<SessionLocalDataSource>(
    () => SessionLocalDataSourceImpl(di<FlutterSecureStorage>()),
  );

  di.registerLazySingleton<SaveAccessTokenUseCase>(
    () => SaveAccessTokenUseCase(di<SessionRepository>()),
  );
  di.registerLazySingleton<ReadAccessTokenUseCase>(
    () => ReadAccessTokenUseCase(di<SessionRepository>()),
  );
  di.registerLazySingleton<ClearAccessTokenUseCase>(
    () => ClearAccessTokenUseCase(di<SessionRepository>()),
  );

  di.registerLazySingleton<SessionBloc>(
    () => SessionBloc(
      di<SaveAccessTokenUseCase>(),
      di<ReadAccessTokenUseCase>(),
      di<ClearAccessTokenUseCase>(),
      di<ClearAllBoxesUseCase>(),
    ),
  );
}
