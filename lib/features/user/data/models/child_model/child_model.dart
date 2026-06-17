import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/child_entity/child_entity.dart';

part 'child_model.freezed.dart';
part 'child_model.g.dart';

@freezed
abstract class ChildModel with _$ChildModel {
  const factory ChildModel({
    required String nis,
    required String nama,
    required String kelas,
    @JsonKey(name: 'foto') String? profileImageUrl,
  }) = _ChildModel;

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      _$ChildModelFromJson(json);
}

extension ChildModelMapper on ChildModel {
  ChildEntity toEntity() => ChildEntity(
    nis: nis,
    nama: nama,
    kelas: kelas,
    profileImageUrl: profileImageUrl,
  );
}
