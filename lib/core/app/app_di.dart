// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../di/get_it_constant.dart';
import '../localizations/localization_storage.dart';
import '../theme/theme_storage.dart';
import 'bloc/app_bloc.dart';

void initAppDI() {
  di.registerLazySingleton<AppBloc>(
    () => AppBloc(di<ThemeStorage>(), di<LocalizationStorage>()),
  );
}
