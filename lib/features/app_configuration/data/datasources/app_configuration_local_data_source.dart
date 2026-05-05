// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';
import '../models/app_configuration_model/app_configuration_model.dart';

/// Penjaga gudang lokal (Data Source) buat simpen config app.
///
/// Dia yang tanggung jawab simpen dan baca data [AppConfigurationModel]
/// dari memori HP pake [Hive].
abstract class AppConfigurationLocalDataSource
    implements CacheStorage<AppConfigurationModel> {}

/// Implementasi nyata dari [AppConfigurationLocalDataSource].
class AppConfigurationLocalDataSourceImpl
    implements AppConfigurationLocalDataSource {
  /// Butuh [_hiveInterface] biar bisa buka-tutup kotak penyimpanan.
  AppConfigurationLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  @override
  AppConfigurationModel? read() {
    final rawData = _hiveInterface
        .box(HiveStorageBoxNames.appBoxKey)
        .get(HiveStorageNames.appConfigurationKey);

    if (rawData == null) return null;

    return AppConfigurationModel.fromJson(Map<String, dynamic>.from(rawData));
  }

  @override
  Future<Unit> save(AppConfigurationModel data) async {
    await _hiveInterface
        .box(HiveStorageBoxNames.appBoxKey)
        .put(HiveStorageNames.appConfigurationKey, data.toJson());

    return unit;
  }
}
