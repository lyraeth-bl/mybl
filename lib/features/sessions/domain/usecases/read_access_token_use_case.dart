// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../repositories/session_repository.dart';

/// Si "Tukang Ngintip" token yang lagi aktif.
///
/// [ReadAccessTokenUseCase] ini berguna banget pas kita butuh tau apakah
/// user lagi punya sesi aktif atau nggak. Dia bakal minta tolong ke
/// [SessionRepository] buat ngambilin token yang (mungkin) ada di storage.
class ReadAccessTokenUseCase {
  ReadAccessTokenUseCase(this._sessionRepository);

  final SessionRepository _sessionRepository;

  /// Ngambil token akses dari persembunyiannya.
  ///
  /// Returns [String] tokennya kalau emang ada, atau `null` kalau user
  /// lagi nggak login alias storagenya kosong.
  Future<String?> call() => _sessionRepository.readAccessToken();
}
