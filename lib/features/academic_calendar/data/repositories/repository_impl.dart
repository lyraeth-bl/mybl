import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/academic_calendar_entity.dart';
import '../../domain/repositories/repository.dart';
import '../datasources/local.dart';
import '../datasources/remote.dart';
import '../models/academic_calendar_model/academic_calendar_model.dart';

class AcademicCalendarRepositoryImpl implements AcademicCalendarRepository {
  AcademicCalendarRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final AcademicCalendarRemoteDataSource _remoteDataSource;
  final AcademicCalendarLocalDataSource _localDataSource;

  @override
  Future<Result<List<AcademicCalendarEntity>?>> fetchAcademicCalendar({
    required int year,
    required int month,
    required String unit,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final storedListData = _localDataSource.readMonthlyAcademicCalendar(
        month: month,
        year: year,
      );

      if (storedListData != null) {
        final storedData = storedListData.map((m) => m.toEntity()).toList();

        return right(storedData);
      }
    }

    try {
      final response = await _remoteDataSource.fetchAcademicCalendar(
        year: year,
        month: month,
        unit: unit,
      );

      if (response.academicCalendar == null) return right(null);

      await _localDataSource.saveMonthlyAcademicCalendar(
        month: month,
        year: year,
        listData: response.academicCalendar!,
      );

      final convertToEntity = response.academicCalendar!
          .map((m) => m.toEntity())
          .toList();

      return right(convertToEntity);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
