// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/device_token/domain/usecases/register_use_case.dart';
import '../../features/notifications/data/datasources/notification_local_data_source.dart';
import '../di/get_it_constant.dart';
import 'fcm_service.dart';

void initFCMServiceDI() {
  di.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);

  di.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin.new,
  );

  di.registerLazySingleton<FCMService>(
    () => FCMService(
      di<FirebaseMessaging>(),
      di<FlutterLocalNotificationsPlugin>(),
      di<NotificationLocalDataSource>(),
      di<RegisterDeviceTokenUseCase>(),
    ),
  );
}
