// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sarpras_teacher_candidate.freezed.dart';

@freezed
abstract class SarprasTeacherCandidate with _$SarprasTeacherCandidate {
  const factory SarprasTeacherCandidate({
    required String nip,
    required String name,
  }) = _SarprasTeacherCandidate;
}
