// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_configuration_entity.freezed.dart';

@freezed
abstract class AppConfigurationEntity with _$AppConfigurationEntity {
  const factory AppConfigurationEntity({
    required int id,
    String? androidAppLink,
    String? iosAppLink,
    String? androidAppVersion,
    String? iosAppVersion,
    @Default(false) bool forceAppUpdate,
    @Default(false) bool appMaintenance,
    String? fileUploadSizeLimit,
  }) = _AppConfigurationEntity;
}
