// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/auth_response_entity/auth_response_entity.dart';
import '../entities/login_params/login_params.dart';
import '../repositories/auth_repository.dart';

/// UseCase khusus buat nanganin proses login.
///
/// Tugasnya simpel: nerima [LoginParams] dari UI, terus nyuruh [AuthRepository]
/// buat eksekusi proses login-nya. Ini bagian dari Clean Architecture biar
/// logic bisnis nggak kecampur aduk.
class LoginUseCase {
  /// Bikin instance [LoginUseCase] bareng [_authRepository] andalannya.
  LoginUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Jalanin aksi login pake [params] yang dikasih.
  ///
  /// Returns [Result] isinya data user kalau sukses, atau [Failure] kalau gagal.
  Future<Result<AuthResponseEntity>> call(LoginParams params) =>
      _authRepository.login(nis: params.nis, password: params.password);
}
