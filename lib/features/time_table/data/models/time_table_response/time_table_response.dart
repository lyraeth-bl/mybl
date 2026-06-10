// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../time_table/time_table_model.dart';

part 'time_table_response.freezed.dart';
part 'time_table_response.g.dart';

@freezed
abstract class TimeTableResponse with _$TimeTableResponse {
  const factory TimeTableResponse({
    required bool status,
    required String message,
    @JsonKey(name: "data") required List<TimeTableModel> listTimeTable,
  }) = _TimeTableResponse;

  factory TimeTableResponse.fromJson(Map<String, dynamic> json) =>
      _$TimeTableResponseFromJson(json);
}
