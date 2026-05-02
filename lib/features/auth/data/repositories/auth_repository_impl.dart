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

/// Si paling sibuk yang jadi jembatan antara dunia luar (API/Local) sama logic bisnis kita.
///
/// [AuthRepositoryImpl] ini tugasnya berat tapi mulia: dia yang ngatur kapan harus
/// manggil [AuthRemoteDataSource] buat urusan internet, atau [AuthLocalDataSource]
/// pas lagi butuh data di dalem hape. Selain itu, dia juga tukang sortir yang
/// ngerapiin error jadi [Failure] biar domain layer nggak pusing bacanya.
class AuthRepositoryImpl implements AuthRepository {
  /// Bikin instance [AuthRepositoryImpl] bareng dua partner andalannya,
  /// [_remoteDataSource] buat urusan cloud dan [_localDataSource] buat local storage.
  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  /// Proses login yang bakal nyuruh [_remoteDataSource] buat verifikasi ke server.
  ///
  /// Pas dapet respon, dia bakal otomatis konversi datanya jadi [AuthResponseEntity]
  /// biar bisa langsung dipake. Kalo ada yang error (misal internet mati atau
  /// salah password), dia bakal bungkus error-nya jadi [Failure] yang rapi.
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

  /// Ritual pamitan biar user bisa keluar dari aplikasi dengan aman.
  ///
  /// Method ini bakal manggil [_remoteDataSource] buat ngasih tau server kalo
  /// kita udah kelar. Hasilnya dibungkus pake [Result] biar kita tau sukses
  /// atau malah ada masalah pas lagi proses logout.
  @override
  Future<Result<Unit>> logout() async {
    try {
      await _remoteDataSource.logout();

      return right(unit);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  /// Ngintip data NIS yang udah pernah disimpen di hape.
  ///
  /// Langsung nanya ke [_localDataSource] dan bakal ngasih [String] kalo ada,
  /// atau `null` kalo ternyata memorinya masih kosong melompong.
  @override
  Future<String?> readNIS() async => await _localDataSource.readNIS();

  /// Titip simpen NIS user biar nggak ilang-ilangan.
  ///
  /// Pake [_localDataSource] buat mastiin data [nis] kesimpen dengan bener
  /// di storage lokal perangkat.
  @override
  Future<Unit> saveNIS(String nis) async => await _localDataSource.saveNIS(nis);
}
