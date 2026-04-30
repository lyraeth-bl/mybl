// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:hive_ce/hive_ce.dart';

import '../di/get_it_constant.dart';
import 'localization_storage.dart';

void initLocalizationDI() {
  di.registerLazySingleton<LocalizationStorage>(
    () => LocalizationStorage(di<HiveInterface>()),
  );
}
