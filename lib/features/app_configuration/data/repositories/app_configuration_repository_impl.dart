// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/app_configuration_entity/app_configuration_entity.dart';
import '../../domain/repositories/app_configuration_repository.dart';
import '../datasources/app_configuration_local_data_source.dart';
import '../datasources/app_configuration_remote_data_source.dart';
import '../models/app_configuration_model/app_configuration_model.dart';

class AppConfigurationRepositoryImpl implements AppConfigurationRepository {
  AppConfigurationRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final AppConfigurationLocalDataSource _localDataSource;
  final AppConfigurationRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AppConfigurationEntity>> fetch([
    bool forceRefresh = false,
  ]) async {
    if (!forceRefresh) {
      final storedData = _localDataSource.read();

      if (storedData != null) return right(storedData.toEntity());
    }

    try {
      final response = await _remoteDataSource.fetch();

      await _localDataSource.save(response.appConfiguration.first);

      return right(response.appConfiguration.first.toEntity());
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
