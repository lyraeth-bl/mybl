// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../student_model/student_model.dart';

part 'student_response.freezed.dart';
part 'student_response.g.dart';

@freezed
abstract class StudentResponse with _$StudentResponse {
  const factory StudentResponse({
    required bool error,
    @JsonKey(name: 'data') required StudentModel student,
  }) = _StudentResponse;

  factory StudentResponse.fromJson(Map<String, dynamic> json) =>
      _$StudentResponseFromJson(json);
}
