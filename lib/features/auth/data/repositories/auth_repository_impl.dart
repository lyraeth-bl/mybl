// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/auth_response_entity/auth_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model/auth_response_model.dart';
import '../models/login_request/login_request.dart';

/// Jembatan (Repository) yang nyambungin antara data source sama logic bisnis.
///
/// Tugasnya:
/// 1. Nyuruh [AuthRemoteDataSource] buat ambil data.
/// 2. Konversi (mapping) model dari API jadi Entity biar bisa dipake domain layer.
/// 3. Nangkep error dan bungkus jadi [Failure] biar seragam.
class AuthRepositoryImpl implements AuthRepository {
  /// Bikin instance bareng [_remoteDataSource] andalannya.
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

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
      // Kalau gagal, langsung jadiin Failure biar rapi.
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
}
