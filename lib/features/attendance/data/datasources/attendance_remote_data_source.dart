// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/daily_attendance_response/daily_attendance_response.dart';
import '../models/monthly_attendance_response/monthly_attendance_response.dart';

abstract class AttendanceRemoteDataSource {
  Future<MonthlyAttendanceResponse> fetchMonthlyAttendance({
    required int month,
    required int year,
  });

  Future<DailyAttendanceResponse> fetchDailyAttendance();
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  AttendanceRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<DailyAttendanceResponse> fetchDailyAttendance() async {
    final response = await _httpRequest.get(ApiEndpoints.todayAttendance);

    return DailyAttendanceResponse.fromJson(response);
  }

  @override
  Future<MonthlyAttendanceResponse> fetchMonthlyAttendance({
    required int month,
    required int year,
  }) async {
    final Map<String, dynamic> query = {'month': month, 'year': year};

    final response = await _httpRequest.get(
      ApiEndpoints.attendance,
      queryParameters: query,
    );

    return MonthlyAttendanceResponse.fromJson(response);
  }
}
