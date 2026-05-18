// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';
import '../models/time_table/time_table_model.dart';

abstract class TimeTableLocalDataSource
    implements TimeTableLocalManager<TimeTableModel> {}

class TimeTableLocalDataSourceImpl implements TimeTableLocalDataSource {
  TimeTableLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  @override
  List<TimeTableModel>? readListTimeTable() {
    final rawListData = _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .get(HiveStorageNames.userTimeTableKey);

    if (rawListData == null) return null;

    return (rawListData as List<dynamic>?)
        ?.map((m) => TimeTableModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  Future<Unit> saveListTimeTable({
    required List<TimeTableModel> listData,
  }) async {
    final timeTableList = listData.map((m) => m.toJson()).toList();

    await _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .put(HiveStorageNames.userTimeTableKey, timeTableList);

    return unit;
  }
}
