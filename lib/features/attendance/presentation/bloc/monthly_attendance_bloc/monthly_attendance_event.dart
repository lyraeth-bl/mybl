part of 'monthly_attendance_bloc.dart';

@freezed
sealed class MonthlyAttendanceEvent with _$MonthlyAttendanceEvent {
  const factory MonthlyAttendanceEvent.monthChangeRequested({
    required int month,
    required int year,
    @Default(false) bool forceRefresh,
  }) = _MonthChangeRequested;
}
