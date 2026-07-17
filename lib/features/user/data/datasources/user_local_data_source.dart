// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';
import '../models/student_model/student_model.dart';

abstract class UserLocalDataSource implements CacheStorage<StudentModel> {}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  UserLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  @override
  StudentModel? read() {
    final rawData = _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .get(HiveStorageNames.studentDetailKey);

    if (rawData == null) return null;

    return StudentModel.fromJson(Map<String, dynamic>.from(rawData));
  }

  @override
  Future<Unit> save(StudentModel data) async {
    // Strip password fields sebelum disimpen ke Hive
    final safeData = data.copyWith(passsword: null, passwordOrangTua: '');

    // Simpen datanya ke box Hive dalam bentuk JSON biar awet.
    await _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .put(HiveStorageNames.studentDetailKey, safeData.toJson());

    return unit;
  }
}
