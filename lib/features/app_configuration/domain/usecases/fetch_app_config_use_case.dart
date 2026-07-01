// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/enums/user_role.dart';
import '../../../../core/internal/src/types.dart';
import '../entities/app_configuration_entity/app_configuration_entity.dart';
import '../repositories/app_configuration_repository.dart';

/// Jasa titip buat ngambil konfigurasi aplikasi.
///
/// Tugasnya simpel: panggil [AppConfigurationRepository] buat cari tau
/// ada update apa aja di aplikasi kita.
class FetchAppConfigUseCase {
  /// Butuh [_appConfigurationRepository] buat kerja.
  FetchAppConfigUseCase(this._appConfigurationRepository);

  final AppConfigurationRepository _appConfigurationRepository;

  Future<Result<AppConfigurationEntity>> call({
    required UserRole role,
    bool forceRefresh = false,
  }) => _appConfigurationRepository.fetch(role: role, forceRefresh: forceRefresh);
}
