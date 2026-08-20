// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:hive_ce/hive_ce.dart';

import '../../core/di/get_it_constant.dart';
import '../../core/internal/src/interfaces/data_interfaces.dart';
import 'data/datasources/app_configuration_local_data_source.dart';
import 'data/datasources/app_configuration_remote_data_source.dart';
import 'data/repositories/app_configuration_repository_impl.dart';
import 'domain/repositories/app_configuration_repository.dart';
import 'domain/usecases/fetch_app_config_use_case.dart';
import 'presentation/bloc/app_configuration_bloc.dart';

/// Si paling sibuk buat ngurusin Dependency Injection (DI) khusus fitur konfigurasi app.
///
/// Di sini kita daftarin semua "alat tempur" mulai dari [AppConfigurationLocalDataSource],
/// [AppConfigurationRemoteDataSource], sampe [AppConfigurationBloc] biar bisa dipake di mana aja.
void initAppConfigurationDI() {
  di.registerLazySingleton<AppConfigurationLocalDataSource>(
    () => AppConfigurationLocalDataSourceImpl(di<HiveInterface>()),
  );
  di.registerLazySingleton<AppConfigurationRemoteDataSource>(
    () => AppConfigurationRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<AppConfigurationRepository>(
    () => AppConfigurationRepositoryImpl(
      di<AppConfigurationLocalDataSource>(),
      di<AppConfigurationRemoteDataSource>(),
    ),
  );

  di.registerLazySingleton<FetchAppConfigUseCase>(
    () => FetchAppConfigUseCase(di<AppConfigurationRepository>()),
  );

  // Lazy singleton: status maintenance dibaca gate global di atas seluruh
  // rute, jadi satu instance harus hidup lebih lama dari layar mana pun.
  di.registerLazySingleton<AppConfigurationBloc>(
    () => AppConfigurationBloc(di<FetchAppConfigUseCase>()),
  );
}
