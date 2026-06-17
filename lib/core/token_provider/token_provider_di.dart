// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../features/sessions/data/datasources/session_local_data_source.dart';
import '../di/get_it_constant.dart';
import 'parent_token_provider.dart';
import 'token_provider.dart';

void initTokenProviderDI() {
  di.registerLazySingleton<TokenProvider>(
    () => TokenProviderImpl(di<SessionLocalDataSource>()),
  );

  di.registerLazySingleton<ParentTokenProvider>(
    () => ParentTokenProviderImpl(di<SessionLocalDataSource>()),
  );
}
