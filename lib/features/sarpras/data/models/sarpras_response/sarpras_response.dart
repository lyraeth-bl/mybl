// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../sarpras_model/sarpras_model.dart';

part 'sarpras_response.freezed.dart';
part 'sarpras_response.g.dart';

@freezed
abstract class SarprasResponse with _$SarprasResponse {
  const factory SarprasResponse({
    required bool error,
    @JsonKey(name: 'ringkasan') required SarprasSummaryModel summary,
    @JsonKey(name: 'data')
    @Default(<SarprasModel>[])
    List<SarprasModel> listSarpras,
  }) = _SarprasResponse;

  factory SarprasResponse.fromJson(Map<String, dynamic> json) =>
      _$SarprasResponseFromJson(json);
}
