// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../repositories/auth_repository.dart';

/// Use case si paling pelupa yang tugasnya cuma satu: ngambil data NIS yang udah tersimpan.
///
/// [ReadNisUseCase] ini jadi jembatan buat lo dapetin NIS dari [AuthRepository]
/// tanpa ribet. Cocok banget dipake pas lo butuh ngecek apakah user udah pernah
/// login atau cuma sekedar butuh ID mereka buat fetch data lain.
class ReadNisUseCase {
  /// Bikin instance [ReadNisUseCase] sambil nitipin [AuthRepository]
  /// yang bakal dieksekusi nantinya.
  ReadNisUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Langsung eksekusi buat dapetin NIS.
  ///
  /// Method [call] ini bakal ngembaliin [String] kalo NIS ketemu,
  /// tapi bisa juga `null` kalo ternyata datanya emang belum ada atau
  /// user-nya belum pernah input apa-apa.
  Future<String?> call() => _authRepository.readNIS();
}
