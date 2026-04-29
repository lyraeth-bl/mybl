// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:my_bl/core/app_router/app_router.dart';
import 'package:my_bl/core/theme/theme.dart';

import '../di/get_it_constant.dart';

class MyBLApp extends StatelessWidget {
  const MyBLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: di<AppRouter>().goRouter,
      theme: BLTheme.lightTheme,
      darkTheme: BLTheme.darkTheme,
    );
  }
}
