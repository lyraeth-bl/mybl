// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../api_client/api_client_di.dart';
import '../app_router/app_router_di.dart';
import '../dio_factory/network_di.dart';
import '../localizations/localization_di.dart';
import '../storage/hive_storage/hive_storage_di.dart';
import '../storage/secure_storage/secure_storage_di.dart';
import '../theme/theme_storage_di.dart';
import 'app_bloc_observer.dart';
import 'app_di.dart';

Future<void> initializeApp() async {
  await dotenv.load(fileName: ".env");

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  initAppRouterDI();
  await initHiveStorageDI();
  initSecureStorageDI();
  initLocalizationDI();
  initThemeDI();
  initAppDI();
  initApiClientDI();
  initNetworkDI();

  Bloc.observer = const AppBlocObserver();
}
