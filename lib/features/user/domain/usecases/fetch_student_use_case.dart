// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/student_entity/student_entity.dart';
import '../repositories/user_repository.dart';

/// [FetchStudentUseCase] itu si kurir andalan buat jemput data [StudentEntity].
/// Dia tugasnya simpel: panggil [UserRepository] buat dapetin info siswa.
/// Kalo lo mau maksa ambil data paling baru dari server (skip cache), tinggal
/// set `forceRefresh` jadi `true` pas manggil use case ini.
class FetchStudentUseCase {
  FetchStudentUseCase(this._userRepository);

  final UserRepository _userRepository;

  /// Panggil fungsi ini buat mulai proses penjemputan data.
  /// Bakal balikin [Result] yang isinya bisa [StudentEntity] atau error.
  Future<Result<StudentEntity>> call([bool forceRefresh = false]) =>
      _userRepository.fetch(forceRefresh);
}
