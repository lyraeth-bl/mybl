part of 'parent_daily_attendance_bloc.dart';

@freezed
sealed class ParentDailyAttendanceEvent with _$ParentDailyAttendanceEvent {
  const factory ParentDailyAttendanceEvent.dailyAttendanceRequested({
    @Default(false) bool forceRefresh,
  }) = _DailyAttendanceRequested;
}
