// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../extracurricular/extracurricular.dart';

part 'extracurricular_response.freezed.dart';
part 'extracurricular_response.g.dart';

@freezed
abstract class ExtracurricularResponse with _$ExtracurricularResponse {
  const factory ExtracurricularResponse({
    required bool error,
    required String message,
    @JsonKey(name: "data")
    required List<ExtracurricularModel> listExtracurricular,
  }) = _ExtracurricularResponse;

  factory ExtracurricularResponse.fromJson(Map<String, dynamic> json) =>
      _$ExtracurricularResponseFromJson(json);
}
