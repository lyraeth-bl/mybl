// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../repositories/session_repository.dart';

/// Si paling beres-beres pas user mau cabut (logout).
///
/// [ClearAccessTokenUseCase] ini tugasnya cuma satu: ngebakar atau ngehapus
/// token akses yang kesimpen di storage lewat [SessionRepository].
/// Pas banget dipake pas proses logout biar nggak ada jejak sesi lama yang ketinggalan.
class ClearAccessTokenUseCase {
  ClearAccessTokenUseCase(this._sessionRepository);

  final SessionRepository _sessionRepository;

  /// Eksekusi perintah buat bersihin token.
  ///
  /// Returns [Unit] kalau proses beres-beresnya udah kelar.
  Future<Unit> call() => _sessionRepository.clearAccessToken();
}
