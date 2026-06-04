part of 'daily_attendance_bloc.dart';

@freezed
sealed class DailyAttendanceEvent with _$DailyAttendanceEvent {
  const factory DailyAttendanceEvent.dailyAttendanceRequested({
    @Default(false) bool forceRefresh,
  }) = _DailyAttendanceRequested;
}
