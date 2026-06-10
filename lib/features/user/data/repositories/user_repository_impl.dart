// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/student_entity/student_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/student_model/student_model.dart';

/// [UserRepositoryImpl] adalah "Sang Mandor" yang ngatur alur data.
/// Dia yang mutusin kapan harus ambil data dari memori hp ([UserLocalDataSource])
/// atau kapan harus nembak API ([UserRemoteDataSource]).
///
/// Strateginya simpel: Kalo gak dipaksa refresh (`forceRefresh = false`),
/// dia bakal coba intip data lokal dulu. Kalo kosong, baru deh gas ke server.
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final UserLocalDataSource _localDataSource;
  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<Result<StudentEntity>> fetch([bool forceRefresh = false]) async {
    // Cek dulu di gudang lokal kalo user gak minta maksa refresh.
    if (!forceRefresh) {
      final storedData = _localDataSource.read();

      if (storedData != null) return right(storedData.toEntity());
    }

    // Kalo lokal kosong atau emang mau refresh, baru kita panggil API.
    try {
      final response = await _remoteDataSource.fetch();

      // Jangan lupa simpen hasilnya ke lokal biar besok-besok gak usah nembak API lagi.
      await _localDataSource.save(response.student);

      return right(response.student.toEntity());
    } catch (e, st) {
      // Kalo ada yang error, kita bungkus rapi pake [Failure].
      return left(Failure.fromError(e, st));
    }
  }
}
