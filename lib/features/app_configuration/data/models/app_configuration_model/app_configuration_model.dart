// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/app_configuration_entity/app_configuration_entity.dart';

part 'app_configuration_model.freezed.dart';
part 'app_configuration_model.g.dart';

@freezed
abstract class AppConfigurationModel with _$AppConfigurationModel {
  const factory AppConfigurationModel({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'android_app_link') String? androidAppLink,
    @JsonKey(name: 'ios_app_link') String? iosAppLink,
    @JsonKey(name: 'android_app_version') String? androidAppVersion,
    @JsonKey(name: 'ios_app_version') String? iosAppVersion,
    @JsonKey(name: 'force_app_update') @Default(false) bool forceAppUpdate,
    @JsonKey(name: 'app_maintenance') @Default(false) bool appMaintenance,
    @JsonKey(name: 'file_upload_size_limit') String? fileUploadSizeLimit,
  }) = _AppConfigurationModel;

  factory AppConfigurationModel.fromJson(Map<String, dynamic> json) =>
      _$AppConfigurationModelFromJson(json);
}

extension AppConfigurationModelMapper on AppConfigurationModel {
  AppConfigurationEntity toEntity() => AppConfigurationEntity(
    id: id,
    androidAppLink: androidAppLink,
    androidAppVersion: androidAppVersion,
    appMaintenance: appMaintenance,
    fileUploadSizeLimit: fileUploadSizeLimit,
    forceAppUpdate: forceAppUpdate,
    iosAppLink: iosAppLink,
    iosAppVersion: iosAppVersion,
  );
}
