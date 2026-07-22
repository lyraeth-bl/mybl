// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sarpras_metadata.freezed.dart';

@freezed
abstract class SarprasMetadata with _$SarprasMetadata {
  const factory SarprasMetadata({
    String? keterangan,
    String? aksesResolver,
    String? nipResolver,
    String? nameResolver,
    String? alasanTolak,
    DateTime? resolvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SarprasMetadata;
}
