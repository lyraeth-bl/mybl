// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../l10n/app_localizations.dart';
import '../app_router/app_router.dart';
import '../di/get_it_constant.dart';
import '../theme/app_theme.dart';
import 'app_bloc_provider.dart';
import 'app_force_update_gate.dart';
import 'app_maintenance_gate.dart';
import 'bloc/app_bloc.dart';

class MyBLApp extends StatelessWidget {
  const MyBLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBlocProvider(
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: "MyBL",

            // Nonaktifkan label debug.
            debugShowCheckedModeBanner: false,

            // Route Config.
            routerConfig: di<AppRouter>().goRouter,

            // Gate maintenance dipasang di atas router supaya menutup semua
            // rute, termasuk yang dibuka lewat deep link notifikasi.
            builder: (context, child) => AppMaintenanceGate(
              child: AppForceUpdateGate(
                child: child ?? const SizedBox.shrink(),
              ),
            ),

            // Light sama Dark Theme.
            theme: MyBlTheme.lightTheme,
            darkTheme: MyBlTheme.darkTheme,
            themeMode: state.themeMode,

            // Localization atau Bahasa.
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Bahasa yang di support dalam aplikasi.
            locale: state.locale,
            supportedLocales: [Locale('en'), Locale('id')],
          );
        },
      ),
    );
  }
}
