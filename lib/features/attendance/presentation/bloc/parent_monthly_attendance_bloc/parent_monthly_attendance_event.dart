part of 'parent_monthly_attendance_bloc.dart';

@freezed
sealed class ParentMonthlyAttendanceEvent with _$ParentMonthlyAttendanceEvent {
  const factory ParentMonthlyAttendanceEvent.monthChangeRequested({
    required int month,
    required int year,
    @Default(false) bool forceRefresh,
  }) = _MonthChangeRequested;

  const factory ParentMonthlyAttendanceEvent.previousMonthRequested() =
      _PreviousMonthRequested;

  const factory ParentMonthlyAttendanceEvent.nextMonthRequested() =
      _NextMonthRequested;
}
