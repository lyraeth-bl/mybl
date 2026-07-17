// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/secure_storage_names.dart';

/// Kontrak buat datasource yang ngurusin sesi secara lokal.
///
/// [SessionLocalDataSource] ini cuma janji (interface) kalau siapapun yang
/// mengimplementasikannya harus bisa baca, simpen, dan hapus token.
abstract class SessionLocalDataSource
    implements TokenStorage, ParentTokenStorage, RoleStorage<UserRole> {}

/// Eksekutor utama buat urusan simpen-menyimpan token di perangkat.
///
/// [SessionLocalDataSourceImpl] ini pake [FlutterSecureStorage] sebagai "brangkas"
/// utamanya. Kenapa pake itu? Biar token user aman, nggak gampang diintip
/// sama aplikasi lain atau tangan jahil, karena datanya di-enkripsi sama OS.
class SessionLocalDataSourceImpl implements SessionLocalDataSource {
  SessionLocalDataSourceImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  /// Ngebuka brangkas dan hapus token pake kunci [SecureStorageNames.accessTokenKey].
  @override
  Future<Unit> clearAccessToken() async {
    await _secureStorage.delete(key: SecureStorageNames.accessTokenKey);

    return unit;
  }

  /// Ngintip isi brangkas pake kunci [SecureStorageNames.accessTokenKey].
  ///
  /// Returns tokennya kalau ketemu, atau `null` kalau brangkasnya lagi kosong.
  @override
  Future<String?> readAccessToken() async {
    final rawData = await _secureStorage.read(
      key: SecureStorageNames.accessTokenKey,
    );

    if (rawData == null) return null;

    return rawData;
  }

  /// Nyimpen token ke brangkas biar aman pake kunci [SecureStorageNames.accessTokenKey].
  @override
  Future<Unit> saveAccessToken(String accessToken) async {
    await _secureStorage.write(
      key: SecureStorageNames.accessTokenKey,
      value: accessToken,
    );

    return unit;
  }

  @override
  Future<Unit> clearTokenExpiresAt() async {
    await _secureStorage.delete(key: SecureStorageNames.accessTokenExpiryKey);
    return unit;
  }

  @override
  Future<DateTime?> readTokenExpiresAt() async {
    final raw = await _secureStorage.read(
      key: SecureStorageNames.accessTokenExpiryKey,
    );
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<Unit> saveTokenExpiresAt(DateTime expiresAt) async {
    await _secureStorage.write(
      key: SecureStorageNames.accessTokenExpiryKey,
      value: expiresAt.toIso8601String(),
    );
    return unit;
  }

  @override
  Future<String?> readParentAccessToken() async =>
      _secureStorage.read(key: SecureStorageNames.parentAccessTokenKey);

  @override
  Future<Unit> saveParentAccessToken(String accessToken) async {
    await _secureStorage.write(
      key: SecureStorageNames.parentAccessTokenKey,
      value: accessToken,
    );
    return unit;
  }

  @override
  Future<Unit> clearParentAccessToken() async {
    await _secureStorage.delete(key: SecureStorageNames.parentAccessTokenKey);
    return unit;
  }

  @override
  Future<DateTime?> readParentTokenExpiresAt() async {
    final raw = await _secureStorage.read(
      key: SecureStorageNames.parentAccessTokenExpiryKey,
    );
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<Unit> saveParentTokenExpiresAt(DateTime expiresAt) async {
    await _secureStorage.write(
      key: SecureStorageNames.parentAccessTokenExpiryKey,
      value: expiresAt.toIso8601String(),
    );
    return unit;
  }

  @override
  Future<Unit> clearParentTokenExpiresAt() async {
    await _secureStorage.delete(
      key: SecureStorageNames.parentAccessTokenExpiryKey,
    );
    return unit;
  }

  @override
  Future<Unit> saveRole(UserRole role) async {
    await _secureStorage.write(
      key: SecureStorageNames.userRoleKey,
      value: role.name,
    );
    return unit;
  }

  @override
  Future<UserRole?> readRole() async {
    final raw = await _secureStorage.read(key: SecureStorageNames.userRoleKey);
    if (raw == null) return null;
    return UserRole.values.byName(raw);
  }

  @override
  Future<Unit> clearRole() async {
    await _secureStorage.delete(key: SecureStorageNames.userRoleKey);
    return unit;
  }
}
