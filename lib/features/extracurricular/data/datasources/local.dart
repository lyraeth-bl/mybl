// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';
import '../models/extracurricular/extracurricular.dart';

abstract class ExtracurricularLocalDataSource
    implements ListCacheStorage<ExtracurricularModel> {}

class ExtracurricularLocalDataSourceImpl
    implements ExtracurricularLocalDataSource {
  ExtracurricularLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  @override
  List<ExtracurricularModel>? read() {
    final rawListData = _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .get(HiveStorageNames.userExtracurricularKey);

    if (rawListData == null) return null;

    return (rawListData as List<dynamic>?)
        ?.map(
          (m) => ExtracurricularModel.fromJson(Map<String, dynamic>.from(m)),
        )
        .toList();
  }

  @override
  Future<Unit> save(List<ExtracurricularModel> listData) async {
    final extracurricularList = listData.map((m) => m.toJson()).toList();

    await _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .put(HiveStorageNames.userExtracurricularKey, extracurricularList);

    return unit;
  }
}
