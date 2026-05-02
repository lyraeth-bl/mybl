// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/auth_response_entity/auth_response_entity.dart';
import '../entities/login_params/login_params.dart';
import '../repositories/auth_repository.dart';

/// Si paling pintu masuk. Use case ini tugasnya nanganin proses login biar user
/// bisa dapet akses ke fitur-fitur keren di aplikasi.
///
/// [LoginUseCase] ini cuma butuh [LoginParams] (isinya NIS & password) terus
/// dia bakal minta tolong ke [AuthRepository] buat verifikasi datanya.
class LoginUseCase {
  /// Bikin instance [LoginUseCase] bareng [AuthRepository] andalan lo.
  LoginUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Jalanin aksi login pake data yang ada di [params].
  ///
  /// Method [call] ini bakal ngembaliin [Result] yang isinya data user [AuthResponseEntity]
  /// kalo berhasil, atau [Failure] kalo ternyata login-nya gagal (misal salah password).
  Future<Result<AuthResponseEntity>> call(LoginParams params) =>
      _authRepository.login(nis: params.nis, password: params.password);
}
