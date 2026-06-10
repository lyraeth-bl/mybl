// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';
import '../models/discipline_model/discipline_model.dart';

abstract class DisciplineLocalDataSource
    implements MeritDemeritLocalManager<MeritModel, DemeritModel> {}

class DisciplineLocalDataSourceImpl implements DisciplineLocalDataSource {
  DisciplineLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  @override
  List<DemeritModel>? readListDemerit() {
    final rawListData = _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .get(HiveStorageNames.userDemeritKey);

    if (rawListData == null) return null;

    return (rawListData as List<dynamic>?)
        ?.map((m) => DemeritModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<MeritModel>? readListMerit() {
    final rawListData = _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .get(HiveStorageNames.userMeritKey);

    if (rawListData == null) return null;

    return (rawListData as List<dynamic>?)
        ?.map((m) => MeritModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  Future<Unit> saveListDemerit(List<DemeritModel> listData) async {
    final listDemerit = listData.map((m) => m.toJson()).toList();

    await _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .put(HiveStorageNames.userDemeritKey, listDemerit);

    return unit;
  }

  @override
  Future<Unit> saveListMerit(List<MeritModel> listData) async {
    final listMerit = listData.map((m) => m.toJson()).toList();

    await _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .put(HiveStorageNames.userMeritKey, listMerit);

    return unit;
  }
}
