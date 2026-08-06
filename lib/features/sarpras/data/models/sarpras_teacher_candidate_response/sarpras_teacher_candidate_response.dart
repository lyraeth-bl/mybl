// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../sarpras_teacher_candidate_model/sarpras_teacher_candidate_model.dart';

part 'sarpras_teacher_candidate_response.freezed.dart';
part 'sarpras_teacher_candidate_response.g.dart';

@freezed
abstract class SarprasTeacherCandidateResponse
    with _$SarprasTeacherCandidateResponse {
  const factory SarprasTeacherCandidateResponse({
    required bool error,
    @JsonKey(name: 'data')
    @Default(<SarprasTeacherCandidateModel>[])
    List<SarprasTeacherCandidateModel> listTeacher,
  }) = _SarprasTeacherCandidateResponse;

  factory SarprasTeacherCandidateResponse.fromJson(Map<String, dynamic> json) =>
      _$SarprasTeacherCandidateResponseFromJson(json);
}
