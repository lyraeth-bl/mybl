// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../features/sessions/data/datasources/session_local_data_source.dart';
import '../internal/src/interfaces/data_interfaces.dart';

/// Brangkas cerdas yang pegang kendali atas access token di level core.
///
/// [TokenProvider] ini adalah kontrak buat siapa pun yang mau ngurusin
/// urusan "nitip" atau "ngambil" token secara global di aplikasi.
abstract class TokenProvider implements TokenStorage {}

/// Implementasi nyata dari si penyedia token dengan sistem cache.
///
/// [TokenProviderImpl] ini nggak cuma asal ambil data, tapi dia punya sistem
/// cache di memori (`_cachedToken`). Jadi kalau kita butuh token berkali-kali,
/// dia nggak perlu bolak-balik ngetok pintu storage lokal (yang biasanya lambat),
/// tapi cukup ambil yang ada di kantong (memori) aja.
class TokenProviderImpl implements TokenProvider {
  TokenProviderImpl(this._sessionLocalDataSource);

  final SessionLocalDataSource _sessionLocalDataSource;

  /// Tempat nyimpen token sementara di memori biar aksesnya secepat kilat.
  String? _cachedToken;

  @override
  /// Buang token dari memori. Inget, ini cuma bersihin cache aja ya.
  Future<Unit> clearAccessToken() async {
    _cachedToken = null;

    return unit;
  }

  @override
  /// Ambil token dari cache. Kalau di cache kosong, baru deh dia nanya
  /// ke [SessionLocalDataSource] buat nyari di storage asli.
  Future<String?> readAccessToken() async =>
      _cachedToken ?? _sessionLocalDataSource.readAccessToken();

  @override
  /// Nitip [accessToken] ke cache memori biar gampang diambil nanti.
  Future<Unit> saveAccessToken(String accessToken) async {
    _cachedToken = accessToken;

    return unit;
  }
}
