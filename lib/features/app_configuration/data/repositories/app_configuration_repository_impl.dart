// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/app_configuration_entity/app_configuration_entity.dart';
import '../../domain/repositories/app_configuration_repository.dart';
import '../datasources/app_configuration_local_data_source.dart';
import '../datasources/app_configuration_remote_data_source.dart';
import '../models/app_configuration_model/app_configuration_model.dart';

/// Jembatan andalan buat urusan data konfigurasi aplikasi.
///
/// [AppConfigurationRepositoryImpl] ini yang nentuin kapan kita harus ambil
/// data dari memori HP ([_localDataSource]) dan kapan harus narik dari
/// server ([_remoteDataSource]). Pokoknya dia yang ngatur alur datanya.
class AppConfigurationRepositoryImpl implements AppConfigurationRepository {
  /// Butuh tim lokal dan remote biar kerjanya maksimal.
  AppConfigurationRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final AppConfigurationLocalDataSource _localDataSource;
  final AppConfigurationRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AppConfigurationEntity>> fetch({
    required UserRole role,
    bool forceRefresh = false,
  }) async {
    // Kalau nggak dipaksa refresh, coba intip dulu di lokal ada nggak.
    if (!forceRefresh) {
      final storedData = _localDataSource.read();

      if (storedData != null) return right(storedData.toEntity());
    }

    // Kalau di lokal nggak ada atau emang mau refresh, gas ambil ke server.
    try {
      final response = await _remoteDataSource.fetch(role);

      // Jangan lupa dititipin di lokal biar besok-besok nggak perlu narik lagi.
      await _localDataSource.save(response.appConfiguration.first);

      return right(response.appConfiguration.first.toEntity());
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
