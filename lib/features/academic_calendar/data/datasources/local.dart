import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';
import '../models/academic_calendar_model/academic_calendar_model.dart';

abstract class AcademicCalendarLocalDataSource
    implements AcademicCalendarLocalManager<AcademicCalendarModel> {}

class AcademicCalendarLocalDataSourceImpl
    implements AcademicCalendarLocalDataSource {
  AcademicCalendarLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  String _generateMonthlyKey(int month, int year) {
    return "${HiveStorageNames.userAcademicCalendarKey}_${year}_$month";
  }

  @override
  List<AcademicCalendarModel>? readMonthlyAcademicCalendar({
    required int month,
    required int year,
  }) {
    final rawListData = _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .get(_generateMonthlyKey(month, year));

    if (rawListData == null) return null;

    return (rawListData as List<dynamic>?)
        ?.map(
          (m) => AcademicCalendarModel.fromJson(Map<String, dynamic>.from(m)),
        )
        .toList();
  }

  @override
  Future<Unit> saveMonthlyAcademicCalendar({
    required int month,
    required int year,
    required List<AcademicCalendarModel> listData,
  }) async {
    final listAcademicCalendar = listData.map((m) => m.toJson()).toList();

    await _hiveInterface
        .box(HiveStorageBoxNames.userBoxKey)
        .put(_generateMonthlyKey(month, year), listAcademicCalendar);

    return unit;
  }
}
