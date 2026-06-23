// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'parent_entity.freezed.dart';

/// [ParentEntity] adalah representasi profil orang tua di level domain.
/// Datanya berasal dari endpoint `/parent/me`, mirip [StudentEntity] yang
/// berasal dari `/me`. Daftar anak dan anak yang dipilih bukan bagian dari
/// entity ini — keduanya dikelola terpisah sebagai konteks pemilihan anak.
@freezed
abstract class ParentEntity with _$ParentEntity {
  const factory ParentEntity({
    required int id,
    required String nama,
    required String username,
    required String telpon,
  }) = _ParentEntity;
}
