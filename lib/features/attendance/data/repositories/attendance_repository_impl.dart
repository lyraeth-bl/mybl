// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/attendance_entity/attendance_entity.dart';
import '../../domain/entities/attendance_qr_token/attendance_qr_token.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_data_source.dart';
import '../datasources/attendance_remote_data_source.dart';
import '../models/attendance_model/attendance_model.dart';
import '../models/attendance_qr_token_model/attendance_qr_token_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AttendanceRemoteDataSource _remoteDataSource;
  final AttendanceLocalDataSource _localDataSource;

  @override
  Future<Result<AttendanceQrToken>> fetchQrToken() async {
    try {
      final response = await _remoteDataSource.fetchQrToken();

      return right(response.qrToken.toEntity());
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<AttendanceEntity?>> fetchDailyAttendance([
    bool forceRefresh = false,
  ]) async {
    if (!forceRefresh) {
      final storedData = _localDataSource.readDailyAttendance();

      if (storedData != null) return right(storedData.toEntity());
    }

    try {
      final response = await _remoteDataSource.fetchDailyAttendance();

      if (response.dailyAttendance == null) return right(null);

      // Penggunaan ! disini seharusnya aman karena kalau datanya null
      // udah di handle diatas.
      // Jadi kalau sampe ke code ini, artinya data absensinya memang ada.
      await _localDataSource.saveDailyAttendance(response.dailyAttendance!);

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
    if (!forceRefresh) {
      final storedListData = _localDataSource.readMonthlyAttendance(
        month: month,
        year: year,
      );
      if (storedListData != null) {
        final storedData = storedListData.map((m) => m.toEntity()).toList();
        return right(storedData);
      }
    }

    try {
      final response = await _remoteDataSource.fetchMonthlyAttendance(
        month: month,
        year: year,
      );

      await _localDataSource.saveMonthlyAttendance(
        month: month,
        year: year,
        listData: response.monthlyAttendance,
      );

      final convertToEntity = response.monthlyAttendance
          .map((m) => m.toEntity())
          .toList();

      return right(convertToEntity);
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }
}
