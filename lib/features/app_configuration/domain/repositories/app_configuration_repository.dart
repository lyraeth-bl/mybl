// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/app_configuration_entity/app_configuration_entity.dart';

/// Kontrak kerja buat ngambil data konfigurasi aplikasi.
///
/// Ini cuma interface doang, implementasi nyatanya ada di layer data.
/// Dia bakal ngasih kita [AppConfigurationEntity] lewat [ItemFetcher].
abstract class AppConfigurationRepository
    implements ItemFetcher<AppConfigurationEntity> {}
