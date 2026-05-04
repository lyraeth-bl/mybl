// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../internal/internal.dart';
import '../storage/storage_keys/hive_storage_names.dart';

class LocalizationStorage implements CacheStorage<String> {
  LocalizationStorage(this._hive);

  final HiveInterface _hive;

  @override
  String? read() {
    final languageCode =
        _hive
                .box(HiveStorageBoxNames.appBoxKey)
                .get(HiveStorageNames.appLocalizationsCodeKey)
            as String?;

    if (languageCode == null) return null;

    return languageCode;
  }

  @override
  Future<Unit> save(String data) async {
    await _hive
        .box(HiveStorageBoxNames.appBoxKey)
        .put(HiveStorageNames.appLocalizationsCodeKey, data);

    return unit;
  }
}
