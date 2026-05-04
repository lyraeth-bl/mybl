// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:hive_ce/hive_ce.dart';

import '../../../internal/src/interfaces/data_interfaces.dart';
import '../../storage_keys/hive_storage_names.dart';

/// Si paling tau soal Hive (Data Source) yang fokus ngurusin penyimpanan lokal.
///
/// Ini level paling bawah yang bener-bener megang [HiveInterface] buat
/// eksekusi perintah ke disk. Pokoknya jembatan andalan buat urusan simpan-simpan data.
abstract class StorageLocalDataSource implements LocalStorageManager {}

/// Implementasi nyata dari [StorageLocalDataSource].
///
/// Di sini kita list semua kotak ([Box]) yang mau dipake, kayak buat
/// info app, auth, sampe data user. Ibaratnya ini manajer gudang yang
/// pegang semua kunci kotak penyimpanan kita.
class StorageLocalDataSourceImpl implements StorageLocalDataSource {
  /// Butuh [HiveInterface] biar bisa perintah-perintah Hive.
  StorageLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  /// Daftar kunci kotak yang harus kita buka pas app mulai.
  final List<String> _listBoxesToBeOpen = [
    HiveStorageBoxNames.appBoxKey,
    HiveStorageBoxNames.authBoxKey,
    HiveStorageBoxNames.userBoxKey,
  ];

  /// Daftar kunci kotak yang bakal kita bersihin pas logout.
  ///
  /// Kenapa dipisah? Soalnya ada beberapa kotak yang tetep harus stay
  /// meskipun user logout, contohnya [HiveStorageBoxNames.authBoxKey] dan
  /// [HiveStorageBoxNames.appBoxKey]. Kita masih perlu itu buat simpen
  /// settings atau data non-sensitif lainnya selama app masih ada di HP.
  final List<String> _listBoxesToBeClosed = [HiveStorageBoxNames.userBoxKey];

  @override
  Future<void> openAllBoxes() async {
    for (final key in _listBoxesToBeOpen) {
      await _hiveInterface.openBox(key);
    }
  }

  @override
  Future<void> clearAllBoxes() async {
    for (final key in _listBoxesToBeClosed) {
      await _hiveInterface.box(key).clear();
    }
  }

  @override
  Future<void> closeAllBoxes() async => await _hiveInterface.close();
}
