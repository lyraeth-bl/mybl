// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../internal/internal.dart';
import '../storage/storage_keys/hive_storage_names.dart';

class ThemeStorage implements CacheStorage<ThemeMode> {
  ThemeStorage(this._hive);

  final HiveInterface _hive;

  @override
  ThemeMode? read() {
    final rawData =
        _hive
                .box(HiveStorageBoxNames.appBoxKey)
                .get(HiveStorageNames.appThemeModeKey)
            as String?;

    return switch (rawData) {
      "light" => ThemeMode.light,
      "dark" => ThemeMode.dark,
      "system" => ThemeMode.system,
      _ => null,
    };
  }

  @override
  Future<Unit> save(ThemeMode data) async {
    final themeMode = switch (data) {
      ThemeMode.light => "light",
      ThemeMode.dark => "dark",
      _ => "system",
    };

    await _hive
        .box(HiveStorageBoxNames.appBoxKey)
        .put(HiveStorageNames.appThemeModeKey, themeMode);

    return unit;
  }
}
