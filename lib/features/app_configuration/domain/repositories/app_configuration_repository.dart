// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/enums/user_role.dart';
import '../../../../core/internal/src/types.dart';
import '../entities/app_configuration_entity/app_configuration_entity.dart';

abstract class AppConfigurationRepository {
  Future<Result<AppConfigurationEntity>> fetch({
    required UserRole role,
    bool forceRefresh = false,
  });
}
