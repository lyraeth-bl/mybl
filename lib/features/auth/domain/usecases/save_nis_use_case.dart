// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../repositories/auth_repository.dart';

/// Use case "si paling teliti" yang tugasnya jagain biar NIS user nggak ilang.
///
/// [SaveNisUseCase] ini fungsinya buat nyimpen NIS ke storage lewat [AuthRepository].
/// Biasanya dipake pas user baru pertama kali input NIS atau pas proses login
/// biar kedepannya mereka nggak perlu ngetik ulang terus-terusan.
class SaveNisUseCase {
  /// Bikin instance [SaveNisUseCase] bareng [AuthRepository] andalan lo.
  SaveNisUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Langsung eksekusi buat nyimpen [nis].
  ///
  /// Method [call] ini bakal ngirim data [nis] ke repository buat diproses.
  /// Dia ngembaliin [Unit] (alias 'kosong' tapi tetep berkelas di functional programming)
  /// buat nandain kalo proses simpen-menyimpannya udah beres.
  Future<Unit> call(String nis) => _authRepository.saveNIS(nis);
}
