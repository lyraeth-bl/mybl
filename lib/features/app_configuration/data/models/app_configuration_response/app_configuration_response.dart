// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../app_configuration_model/app_configuration_model.dart';

part 'app_configuration_response.freezed.dart';
part 'app_configuration_response.g.dart';

@freezed
abstract class AppConfigurationResponse with _$AppConfigurationResponse {
  const factory AppConfigurationResponse({
    required bool error,
    @JsonKey(name: "data")
    required List<AppConfigurationModel> appConfiguration,
  }) = _AppConfigurationResponse;

  factory AppConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$AppConfigurationResponseFromJson(json);
}
