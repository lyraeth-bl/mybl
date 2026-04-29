// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'core/app/initialize_app.dart';
import 'core/app/my_bl_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeApp();

  runApp(const MyBLApp());
}
