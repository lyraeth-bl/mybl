import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/enums/user_role.dart';
import '../../../../user/data/models/child_model/child_model.dart';
import '../../../domain/entities/parent_response_entity/parent_response_entity.dart';

part 'parent_response_model.freezed.dart';
part 'parent_response_model.g.dart';

@freezed
abstract class ParentResponseModel with _$ParentResponseModel {
  const factory ParentResponseModel({
    required bool error,
    required String message,
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') required String tokenType,
    @JsonKey(name: "expires_at") required DateTime expiresAt,
    required UserRole role,
    required String nama,
    required List<ChildModel> children,
  }) = _ParentResponseModel;

  factory ParentResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ParentResponseModelFromJson(json);
}

extension ParentResponseModelMapper on ParentResponseModel {
  ParentResponseEntity toEntity() => ParentResponseEntity(
    error: error,
    message: message,
    accessToken: accessToken,
    tokenType: tokenType,
    expiresAt: expiresAt,
    nama: nama,
    children: children.map((e) => e.toEntity()).toList(),
  );
}
