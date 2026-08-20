// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_response_entity.freezed.dart';

@freezed
abstract class AuthResponseEntity with _$AuthResponseEntity {
  const factory AuthResponseEntity({
    required bool error,
    required String message,
    required String accessToken,
    required String tokenType,
    DateTime? expiresAt,
  }) = _AuthResponseEntity;
}
