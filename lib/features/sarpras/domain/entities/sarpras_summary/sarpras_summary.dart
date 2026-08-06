// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sarpras_summary.freezed.dart';

@freezed
abstract class SarprasSummary with _$SarprasSummary {
  const factory SarprasSummary({
    required int waiting,
    required int accepted,
    required int rejected,
  }) = _SarprasSummary;
}
