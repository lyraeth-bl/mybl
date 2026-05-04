// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../di/get_it_constant.dart';
import 'data/datasources/storage_local_data_source.dart';
import 'data/repositories/storage_repository_impl.dart';
import 'domain/repositories/storage_repository.dart';
import 'domain/usecases/clear_all_boxes_use_case.dart';
import 'domain/usecases/close_all_boxes_use_case.dart';
import 'domain/usecases/open_all_boxes_use_case.dart';

Future<void> initStorageDI() async {
  // Register Secure Storage.
  di.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Register Hive.
  await Hive.initFlutter();

  di.registerLazySingleton<HiveInterface>(() => Hive);

  di.registerLazySingleton<StorageLocalDataSource>(
    () => StorageLocalDataSourceImpl(di<HiveInterface>()),
  );

  di.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(di<StorageLocalDataSource>()),
  );

  di.registerLazySingleton<OpenAllBoxesUseCase>(
    () => OpenAllBoxesUseCase(di<StorageRepository>()),
  );
  di.registerLazySingleton<ClearAllBoxesUseCase>(
    () => ClearAllBoxesUseCase(di<StorageRepository>()),
  );
  di.registerLazySingleton<CloseAllBoxesUseCase>(
    () => CloseAllBoxesUseCase(di<StorageRepository>()),
  );
}
