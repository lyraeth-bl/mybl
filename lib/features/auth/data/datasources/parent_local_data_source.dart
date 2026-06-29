// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';

abstract class ParentLocalDataSource implements ParentRememberMeStorage {}

class ParentLocalDataSourceImpl implements ParentLocalDataSource {
  ParentLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  @override
  Future<String?> readUsername() async {
    final rawData =
        await _hiveInterface
                .box(HiveStorageBoxNames.authBoxKey)
                .get(HiveStorageNames.authUsernameKey)
            as String?;

    if (rawData == null) return null;

    return rawData;
  }

  @override
  Future<Unit> saveUsername(String username) async {
    await _hiveInterface
        .box(HiveStorageBoxNames.authBoxKey)
        .put(HiveStorageNames.authUsernameKey, username);

    return unit;
  }
}
