// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../domain/entities/discipline.dart';
import '../discipline_model.dart';

part 'discipline_response.freezed.dart';
part 'discipline_response.g.dart';

@freezed
abstract class MeritResponse with _$MeritResponse {
  const factory MeritResponse({
    required bool status,
    required DisciplineType type,
    required int total,
    @JsonKey(name: "data") List<MeritModel>? listMerit,
  }) = _MeritResponse;

  factory MeritResponse.fromJson(Map<String, dynamic> json) =>
      _$MeritResponseFromJson(json);
}

@freezed
abstract class DemeritResponse with _$DemeritResponse {
  const factory DemeritResponse({
    required bool status,
    required DisciplineType type,
    required int total,
    @JsonKey(name: "data") List<DemeritModel>? listDemerit,
  }) = _DemeritResponse;

  factory DemeritResponse.fromJson(Map<String, dynamic> json) =>
      _$DemeritResponseFromJson(json);
}
