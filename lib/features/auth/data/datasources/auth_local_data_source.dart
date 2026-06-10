// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';

/// Kontrak buat ngurusin data auth di level lokal.
///
/// Class ini sebenernya cuma jembatan biar kita bisa akses fitur [RememberMeStorage]
/// di dalam fitur auth. Jadi semua urusan simpan-menyimpan NIS buat
/// fitur "Remember Me" bakal lewat sini.
abstract class AuthLocalDataSource implements RememberMeStorage {}

/// Implementasi nyata buat [AuthLocalDataSource] yang pake Hive sebagai gudangnya.
///
/// Si paling rajin nyatet NIS user biar pas mau login lagi nggak perlu ngetik dari nol.
/// Class ini butuh [_hiveInterface] buat ngobrol langsung sama database Hive.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  /// Nyari NIS yang pernah disimpen di dalam box Hive.
  ///
  /// Kita bakal buka box [HiveStorageBoxNames.authBoxKey] terus cari data pake
  /// key [HiveStorageNames.authNISKey]. Kalau ketemu, datanya dibalikin sebagai
  /// [String], tapi kalau lagi zonk ya dapetnya `null`.
  @override
  Future<String?> readNIS() async {
    final rawData =
        await _hiveInterface
                .box(HiveStorageBoxNames.authBoxKey)
                .get(HiveStorageNames.authNISKey)
            as String?;

    if (rawData == null) return null;

    return rawData;
  }

  /// Nitip NIS user ke dalam box Hive biar awet.
  ///
  /// Data [nis] bakal dimasukin ke box [HiveStorageBoxNames.authBoxKey] pake
  /// key [HiveStorageNames.authNISKey]. Ini dipake pas user sukses login dan
  /// kita mau "inget" siapa yang barusan masuk.
  @override
  Future<Unit> saveNIS(String nis) async {
    await _hiveInterface
        .box(HiveStorageBoxNames.authBoxKey)
        .put(HiveStorageNames.authNISKey, nis);

    return unit;
  }
}
