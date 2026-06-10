part of 'academic_calendar_bloc.dart';

@freezed
sealed class AcademicCalendarEvent with _$AcademicCalendarEvent {
  const factory AcademicCalendarEvent.fetchAcademicCalendar({
    required int year,
    required int month,
    required String unit,
    @Default(false) bool forceRefresh,
  }) = _FetchAcademicCalendar;
}
