// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../sarpras_model/sarpras_model.dart';

part 'sarpras_detail_response.freezed.dart';
part 'sarpras_detail_response.g.dart';

@freezed
abstract class SarprasDetailResponse with _$SarprasDetailResponse {
  const factory SarprasDetailResponse({
    required bool error,
    String? message,
    @JsonKey(name: 'data') SarprasModel? sarpras,
  }) = _SarprasDetailResponse;

  factory SarprasDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$SarprasDetailResponseFromJson(json);
}
