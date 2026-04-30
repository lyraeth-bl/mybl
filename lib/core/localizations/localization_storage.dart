// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../internal/internal.dart';
import '../storage/hive_storage/hive_storage_names.dart';

class LocalizationStorage implements CacheStorage<String> {
  LocalizationStorage(this._hive);

  final HiveInterface _hive;

  @override
  String? read() {
    final languageCode =
        _hive
                .box(HiveStorageBoxNames.userLocalizationsBoxKey)
                .get(HiveStorageNames.userLocalizationsCodeKey)
            as String?;

    if (languageCode == null) return null;

    return languageCode;
  }

  @override
  Future<Unit> save(String data) async {
    await _hive
        .box(HiveStorageBoxNames.userLocalizationsBoxKey)
        .put(HiveStorageNames.userLocalizationsCodeKey, data);

    return unit;
  }
}
