// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../l10n/app_localizations.dart';
import '../app_router/app_router.dart';
import '../di/get_it_constant.dart';
import '../theme/theme.dart';

class MyBLApp extends StatelessWidget {
  const MyBLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "MyBL",

      // Nonaktifkan label debug.
      debugShowCheckedModeBanner: false,

      // Route Config.
      routerConfig: di<AppRouter>().goRouter,

      // Light sama Dark Theme.
      theme: BLTheme.lightTheme,
      darkTheme: BLTheme.darkTheme,

      // Localization atau Bahasa.
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Bahasa yang di support dalam aplikasi.
      supportedLocales: [Locale('en'), Locale('id')],
    );
  }
}
