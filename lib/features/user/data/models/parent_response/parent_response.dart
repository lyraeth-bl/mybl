// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../parent_model/parent_model.dart';

part 'parent_response.freezed.dart';
part 'parent_response.g.dart';

/// Pembungkus response dari endpoint `/parent/me`. Isinya penanda [error]
/// dan data utama profil parent yang sudah di-map ke [ParentModel].
@freezed
abstract class ParentResponse with _$ParentResponse {
  const factory ParentResponse({
    required bool error,
    @JsonKey(name: 'data') required ParentModel parent,
  }) = _ParentResponse;

  factory ParentResponse.fromJson(Map<String, dynamic> json) =>
      _$ParentResponseFromJson(json);
}
