// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/hive_storage/hive_storage_names.dart';
import '../models/student_model/student_model.dart';

abstract class UserLocalDataSource implements CacheStorage<StudentModel> {}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  UserLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  @override
  StudentModel? read() {
    final rawData =
        _hiveInterface
                .box(HiveStorageBoxNames.userBoxKey)
                .get(HiveStorageNames.studentDetailKey)
            as Map<String, dynamic>?;

    if (rawData == null) return null;

    return StudentModel.fromJson(rawData);
  }

  @override
  Future<Unit> save(StudentModel data) async {
    await _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .put(HiveStorageNames.studentDetailKey, data.toJson());

    return unit;
  }
}
