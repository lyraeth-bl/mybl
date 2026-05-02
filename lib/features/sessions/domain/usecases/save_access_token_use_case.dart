// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../repositories/session_repository.dart';

/// Jembatan andalan buat nitipin token baru ke storage.
///
/// [SaveAccessTokenUseCase] ini biasanya beraksi pas user baru aja sukses login.
/// Dia bakal nerima token dari server terus nyuruh [SessionRepository] buat
/// simpen token itu baik-baik biar sesi usernya tetep awet.
class SaveAccessTokenUseCase {
  SaveAccessTokenUseCase(this._sessionRepository);

  final SessionRepository _sessionRepository;

  /// Titip [accessToken] ke storage biar nggak ilang.
  ///
  /// Returns [Unit] kalau tokennya udah aman tersimpan.
  Future<Unit> call(String accessToken) =>
      _sessionRepository.saveAccessToken(accessToken);
}
