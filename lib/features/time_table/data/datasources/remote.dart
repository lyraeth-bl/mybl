// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/time_table_response/time_table_response.dart';

abstract class TimeTableRemoteDataSource {
  Future<TimeTableResponse> fetchAll({required String kelas});
}

class TimeTableRemoteDataSourceImpl implements TimeTableRemoteDataSource {
  TimeTableRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<TimeTableResponse> fetchAll({required String kelas}) async {
    final response = await _httpRequest.get(
      ApiEndpoints.timeTable,
      queryParameters: {'kelas': kelas},
    );

    return TimeTableResponse.fromJson(response);
  }
}
