import 'package:freezed_annotation/freezed_annotation.dart';

import '../academic_calendar_model/academic_calendar_model.dart';

part 'academic_calendar_response.freezed.dart';
part 'academic_calendar_response.g.dart';

@freezed
abstract class AcademicCalendarResponse with _$AcademicCalendarResponse {
  const factory AcademicCalendarResponse({
    required bool error,
    required String message,
    @JsonKey(name: "data")
    required List<AcademicCalendarModel>? academicCalendar,
  }) = _AcademicCalendarResponse;

  factory AcademicCalendarResponse.fromJson(Map<String, dynamic> json) =>
      _$AcademicCalendarResponseFromJson(json);
}
