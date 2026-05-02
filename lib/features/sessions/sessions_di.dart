import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_bl/features/sessions/presentation/bloc/session_bloc.dart';

import '../../core/di/get_it_constant.dart';
import 'data/datasources/session_local_data_source.dart';
import 'data/repositories/session_repository_impl.dart';
import 'domain/repositories/session_repository.dart';
import 'domain/usecases/clear_access_token_use_case.dart';
import 'domain/usecases/read_access_token_use_case.dart';
import 'domain/usecases/save_access_token_use_case.dart';

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
    ),
  );
}
