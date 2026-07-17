// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/parent_entity/parent_entity.dart';

part 'parent_model.freezed.dart';
part 'parent_model.g.dart';

/// [ParentModel] adalah wujud data profil parent dari endpoint `/parent/me`.
/// Mirip [StudentModel] yang berasal dari `/me`.
@freezed
abstract class ParentModel with _$ParentModel {
  const factory ParentModel({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'nama') required String nama,
    @JsonKey(name: 'username') required String username,
    @JsonKey(name: 'telpon') required String telpon,
  }) = _ParentModel;

  factory ParentModel.fromJson(Map<String, dynamic> json) =>
      _$ParentModelFromJson(json);
}

extension ParentModelMapper on ParentModel {
  ParentEntity toEntity() =>
      ParentEntity(id: id, nama: nama, username: username, telpon: telpon);
}
