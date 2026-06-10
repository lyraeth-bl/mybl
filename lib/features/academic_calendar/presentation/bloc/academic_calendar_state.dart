part of 'academic_calendar_bloc.dart';

@freezed
sealed class AcademicCalendarState with _$AcademicCalendarState {
  const factory AcademicCalendarState.initial() = _Initial;

  const factory AcademicCalendarState.loading() = _Loading;

  const factory AcademicCalendarState.success({
    required List<AcademicCalendarEntity> academicCalendar,
    required int year,
    required int month,
  }) = _Success;

  const factory AcademicCalendarState.emptyData() = _EmptyData;

  const factory AcademicCalendarState.failure(Failure failure) = _Failure;
}
