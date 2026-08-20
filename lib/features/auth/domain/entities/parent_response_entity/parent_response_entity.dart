// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../user/domain/entities/child_entity/child_entity.dart';

part 'parent_response_entity.freezed.dart';

@freezed
abstract class ParentResponseEntity with _$ParentResponseEntity {
  const factory ParentResponseEntity({
    required bool error,
    required String message,
    required String accessToken,
    required String tokenType,
    DateTime? expiresAt,
    required String nama,
    required List<ChildEntity> children,
  }) = _ParentResponseEntity;
}
