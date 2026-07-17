// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';

abstract class AuthLocalDataSource implements StudentRememberMeStorage {}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  @override
  Future<String?> readNIS() async {
    final rawData =
        await _hiveInterface
                .box(HiveStorageBoxNames.authBoxKey)
                .get(HiveStorageNames.authNISKey)
            as String?;

    if (rawData == null) return null;

    return rawData;
  }

  @override
  Future<Unit> saveNIS(String nis) async {
    await _hiveInterface
        .box(HiveStorageBoxNames.authBoxKey)
        .put(HiveStorageNames.authNISKey, nis);

    return unit;
  }
}
