import 'package:fpdart/fpdart.dart';

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/parent_response_model/parent_response_model.dart';

abstract class ParentRemoteDataSource {
  Future<ParentResponseModel> login({
    required String nis,
    required String password,
  });

  Future<Unit> logout();
}

class ParentRemoteDataSourceImpl implements ParentRemoteDataSource {
  ParentRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<ParentResponseModel> login({
    required String nis,
    required String password,
  }) async => await _httpRequest
      .post(
        ApiEndpoints.loginParent,
        data: {'username': nis, 'password': password},
      )
      .then(
        (value) =>
            ParentResponseModel.fromJson(Map<String, dynamic>.from(value)),
      );

  @override
  Future<Unit> logout() async => await _httpRequest
      .post(ApiEndpoints.logoutParent, data: {})
      .then((_) => unit);
}
