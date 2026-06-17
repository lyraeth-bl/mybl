import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/internal.dart';
import '../../domain/entities/parent_response_entity/parent_response_entity.dart';
import '../../domain/repositories/parent_auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/parent_remote_data_source.dart';
import '../models/parent_response_model/parent_response_model.dart';

class ParentAuthRepositoryImpl implements ParentAuthRepository {
  ParentAuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AuthLocalDataSource _localDataSource;
  final ParentRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ParentResponseEntity>> login({
    required String nis,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        nis: nis,
        password: password,
      );

      return right(response.toEntity());
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<Unit>> logout() async {
    try {
      await _remoteDataSource.logout();
      return right(unit);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<String?> readNIS() => _localDataSource.readNIS();

  @override
  Future<Unit> saveNIS(String nis) => _localDataSource.saveNIS(nis);
}
