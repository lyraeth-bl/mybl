// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../features/sessions/presentation/bloc/session_bloc.dart';
import '../di/get_it_constant.dart';
import 'app_router.dart';

void initAppRouterDI() {
  di.registerLazySingleton<AppRouter>(() => AppRouter(di<SessionBloc>()));
}
