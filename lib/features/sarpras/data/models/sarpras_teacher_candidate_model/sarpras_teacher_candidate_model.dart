// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/sarpras_teacher_candidate/sarpras_teacher_candidate.dart';

part 'sarpras_teacher_candidate_model.freezed.dart';
part 'sarpras_teacher_candidate_model.g.dart';

@freezed
abstract class SarprasTeacherCandidateModel
    with _$SarprasTeacherCandidateModel {
  const factory SarprasTeacherCandidateModel({
    @JsonKey(name: 'NIP') required String nip,
    @JsonKey(name: 'nama') required String name,
  }) = _SarprasTeacherCandidateModel;

  factory SarprasTeacherCandidateModel.fromJson(Map<String, dynamic> json) =>
      _$SarprasTeacherCandidateModelFromJson(json);
}

extension SarprasTeacherCandidateModelMapper on SarprasTeacherCandidateModel {
  SarprasTeacherCandidate toEntity() =>
      SarprasTeacherCandidate(nip: nip, name: name);
}
