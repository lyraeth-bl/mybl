// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/attendance_entity/attendance_entity.dart';
import '../../domain/repositories/parent_attendance_repository.dart';
import '../datasources/parent_attendance_remote_data_source.dart';
import '../models/attendance_model/attendance_model.dart';

class ParentAttendanceRepositoryImpl implements ParentAttendanceRepository {
  ParentAttendanceRepositoryImpl(this._remoteDataSource);

  final ParentAttendanceRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AttendanceEntity?>> fetchDailyAttendance([
    bool forceRefresh = false,
  ]) async {
    try {
      final response = await _remoteDataSource.fetchDailyAttendance();

      if (response.dailyAttendance == null) return right(null);

      return right(response.dailyAttendance!.toEntity());
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<List<AttendanceEntity>>> fetchMonthlyAttendance({
    required int month,
    required int year,
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _remoteDataSource.fetchMonthlyAttendance(
        month: month,
        year: year,
      );

      final entities = response.monthlyAttendance
          .map((m) => m.toEntity())
          .toList();

      return right(entities);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
