// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/auth_response_entity/auth_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model/auth_response_model.dart';
import '../models/login_request/login_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<Result<AuthResponseEntity>> login({
    required String nis,
    required String password,
  }) async {
    final request = LoginRequest(nis: nis, password: password);

    try {
      final response = await _remoteDataSource.login(request);

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
  Future<String?> readNIS() async => await _localDataSource.readNIS();

  @override
  Future<Unit> saveNIS(String nis) async => await _localDataSource.saveNIS(nis);
}
