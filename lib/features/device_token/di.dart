// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../core/di/get_it_constant.dart';
import '../../core/internal/src/interfaces/data_interfaces.dart';
import 'data/datasources/device_token_metadata_provider.dart';
import 'data/datasources/remote.dart';
import 'data/repositories/device_token_repository_impl.dart';
import 'domain/repositories/repository.dart';
import 'domain/usecases/register_use_case.dart';
import 'domain/usecases/revoke_use_case.dart';

void initDeviceTokenDI() {
  di.registerLazySingleton<DeviceTokenMetadataProvider>(
    DeviceTokenMetadataProviderImpl.new,
  );

  di.registerLazySingleton<DeviceTokenRemoteDataSource>(
    () => DeviceTokenRemoteDataSourceImpl(di<HTTPRequest>()),
  );

  di.registerLazySingleton<DeviceTokenRepository>(
    () => DeviceTokenRepositoryImpl(
      di<DeviceTokenRemoteDataSource>(),
      di<DeviceTokenMetadataProvider>(),
    ),
  );

  di.registerLazySingleton<RegisterDeviceTokenUseCase>(
    () => RegisterDeviceTokenUseCase(di<DeviceTokenRepository>()),
  );

  di.registerLazySingleton<RevokeDeviceTokenUseCase>(
    () => RevokeDeviceTokenUseCase(di<DeviceTokenRepository>()),
  );
}
