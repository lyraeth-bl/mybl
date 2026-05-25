// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:hive_ce/hive_ce.dart';

import '../../core/di/get_it_constant.dart';
import 'data/datasources/notification_local_data_source.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/usecases/mark_notification_as_read_use_case.dart';
import 'domain/usecases/read_notifications_use_case.dart';
import 'presentation/bloc/notification_bloc.dart';

void initNotificationsDI() {
  di.registerLazySingleton<NotificationLocalDataSource>(
    () => NotificationLocalDataSourceImpl(di<HiveInterface>()),
  );

  di.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(di<NotificationLocalDataSource>()),
  );

  di.registerLazySingleton<ReadNotificationsUseCase>(
    () => ReadNotificationsUseCase(di<NotificationRepository>()),
  );
  di.registerLazySingleton<MarkNotificationAsReadUseCase>(
    () => MarkNotificationAsReadUseCase(di<NotificationRepository>()),
  );

  di.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      di<ReadNotificationsUseCase>(),
      di<MarkNotificationAsReadUseCase>(),
    ),
  );
}
