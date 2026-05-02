// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/internal/src/types.dart';
import '../repositories/auth_repository.dart';

/// Si paling pamit. Use case ini fungsinya buat nanganin proses logout biar user
/// bisa keluar dengan tenang dari aplikasi.
///
/// [LogoutUseCase] bakal manggil [AuthRepository] buat beresin session atau
/// hapus token yang masih nyangkut.
class LogoutUseCase {
  /// Bikin instance [LogoutUseCase] bareng [AuthRepository] kesayangan lo.
  LogoutUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Langsung eksekusi buat logout.
  ///
  /// Method [call] ini bakal ngasih tau kita lewat [Result] apakah proses
  /// keluar-nya lancar jaya atau malah ada kendala di jalan.
  Future<Result<Unit>> call() => _authRepository.logout();
}
