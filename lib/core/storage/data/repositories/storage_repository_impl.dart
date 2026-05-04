// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../domain/repositories/storage_repository.dart';
import '../datasources/storage_local_data_source.dart';

/// Implementasi [StorageRepository] yang tugasnya cuma jadi jembatan
/// ke [StorageLocalDataSource].
///
/// Kenapa dipisah begini? Biar kalau suatu saat kita mau ganti dari Hive
/// ke database lain, domain kita nggak perlu ikutan pusing.
class StorageRepositoryImpl implements StorageRepository {
  StorageRepositoryImpl(this._localDataSource);

  final StorageLocalDataSource _localDataSource;

  @override
  Future<void> clearAllBoxes() async => await _localDataSource.clearAllBoxes();

  @override
  Future<void> closeAllBoxes() async => await _localDataSource.closeAllBoxes();

  @override
  Future<void> openAllBoxes() async => await _localDataSource.openAllBoxes();
}
