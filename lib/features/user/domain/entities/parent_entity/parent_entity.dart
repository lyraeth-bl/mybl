import 'package:freezed_annotation/freezed_annotation.dart';

import '../child_entity/child_entity.dart';

part 'parent_entity.freezed.dart';

@freezed
abstract class ParentEntity with _$ParentEntity {
  const ParentEntity._();

  const factory ParentEntity({
    required String nama,
    required List<ChildEntity> children,
    required ChildEntity selectedChild,
  }) = _ParentEntity;

  String get activeNis => selectedChild.nis;
}
