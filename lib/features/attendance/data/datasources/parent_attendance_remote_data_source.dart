// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/daily_attendance_response/daily_attendance_response.dart';
import '../models/monthly_attendance_response/monthly_attendance_response.dart';

abstract class ParentAttendanceRemoteDataSource {
  Future<DailyAttendanceResponse> fetchDailyAttendance();

  Future<MonthlyAttendanceResponse> fetchMonthlyAttendance({
    required int month,
    required int year,
  });
}

class ParentAttendanceRemoteDataSourceImpl
    implements ParentAttendanceRemoteDataSource {
  ParentAttendanceRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<DailyAttendanceResponse> fetchDailyAttendance() async {
    final response = await _httpRequest.get(ApiEndpoints.parentTodayAttendance);

    return DailyAttendanceResponse.fromJson(response);
  }

  @override
  Future<MonthlyAttendanceResponse> fetchMonthlyAttendance({
    required int month,
    required int year,
  }) async {
    final Map<String, dynamic> query = {'month': month, 'year': year};

    final response = await _httpRequest.get(
      ApiEndpoints.parentAttendance,
      queryParameters: query,
    );

    return MonthlyAttendanceResponse.fromJson(response);
  }
}
