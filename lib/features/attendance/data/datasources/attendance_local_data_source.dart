// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';
import '../models/attendance_model/attendance_model.dart';

abstract class AttendanceLocalDataSource
    implements AttendanceLocalManager<AttendanceModel> {}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  AttendanceLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  String _generateMonthlyAttendanceKey(int month, int year) {
    return "${HiveStorageNames.userMonthlyAttendanceKey}_${year}_$month";
  }

  String _generateDailyAttendanceKey() {
    final now = DateTime.now();
    return '${HiveStorageNames.userDailyAttendanceKey}_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
  }

  @override
  AttendanceModel? readDailyAttendance() {
    final rawData = _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .get(_generateDailyAttendanceKey());

    if (rawData == null) return null;

    return AttendanceModel.fromJson(Map<String, dynamic>.from(rawData));
  }

  @override
  List<AttendanceModel>? readMonthlyAttendance({
    required int month,
    required int year,
  }) {
    final rawListData = _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .get(_generateMonthlyAttendanceKey(month, year));

    if (rawListData == null) return null;

    return (rawListData as List<dynamic>?)
        ?.map(
          (model) => AttendanceModel.fromJson(Map<String, dynamic>.from(model)),
        )
        .toList();
  }

  @override
  Future<Unit> saveDailyAttendance(AttendanceModel data) async {
    await _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .put(_generateDailyAttendanceKey(), data.toJson());

    return unit;
  }

  @override
  Future<Unit> saveMonthlyAttendance({
    required int month,
    required int year,
    required List<AttendanceModel> listData,
  }) async {
    final attendanceList = listData.map((model) => model.toJson()).toList();

    await _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .put(_generateMonthlyAttendanceKey(month, year), attendanceList);

    return unit;
  }
}
