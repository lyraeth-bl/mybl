import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/parent_entity/parent_entity.dart';
import '../child_model/child_model.dart';

part 'parent_model.freezed.dart';
part 'parent_model.g.dart';

@freezed
abstract class ParentModel with _$ParentModel {
  const factory ParentModel({
    @JsonKey(name: 'token') required String token,
    @JsonKey(name: 'nama') required String nama,
    @JsonKey(name: 'role') required String role,
    @JsonKey(name: 'children') required List<ChildModel> children,
  }) = _ParentModel;

  factory ParentModel.fromJson(Map<String, dynamic> json) =>
      _$ParentModelFromJson(json);
}

extension ParentModelMapper on ParentModel {
  ParentEntity toEntity() {
    final childEntities = children.map((c) => c.toEntity()).toList();
    return ParentEntity(
      nama: nama,
      children: childEntities,
      selectedChild: childEntities.first,
    );
  }
}
