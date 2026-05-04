// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../di/get_it_constant.dart';
import 'hive_storage_names.dart';

Future<void> initHiveStorageDI() async {
  await Hive.initFlutter();

  await Hive.openBox(HiveStorageBoxNames.userLocalizationsBoxKey);
  await Hive.openBox(HiveStorageBoxNames.userThemeBoxKey);
  await Hive.openBox(HiveStorageBoxNames.authBoxKey);
  await Hive.openBox(HiveStorageBoxNames.userBoxKey);

  di.registerLazySingleton<HiveInterface>(() => Hive);
}
