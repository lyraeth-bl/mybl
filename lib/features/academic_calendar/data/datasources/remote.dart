import '../../../../core/api_client/api_client.dart';
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../models/academic_calendar_response/academic_calendar_response.dart';

abstract class AcademicCalendarRemoteDataSource {
  Future<AcademicCalendarResponse> fetchAcademicCalendar({
    required int year,
    required int month,
    required String unit,
  });
}

class AcademicCalendarRemoteDataSourceImpl
    implements AcademicCalendarRemoteDataSource {
  AcademicCalendarRemoteDataSourceImpl(this._httpRequest);

  final HTTPRequest _httpRequest;

  @override
  Future<AcademicCalendarResponse> fetchAcademicCalendar({
    required int year,
    required int month,
    required String unit,
  }) async {
    final response = await _httpRequest.get(
      "${ApiEndpoints.academicCalendar}/$year/$month/$unit",
    );

    return AcademicCalendarResponse.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}
