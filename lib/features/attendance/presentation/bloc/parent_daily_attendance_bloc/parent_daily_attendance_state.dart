part of 'parent_daily_attendance_bloc.dart';

@freezed
sealed class ParentDailyAttendanceState with _$ParentDailyAttendanceState {
  const factory ParentDailyAttendanceState.initial() = _Initial;

  const factory ParentDailyAttendanceState.loading() = _Loading;

  const factory ParentDailyAttendanceState.success({
    AttendanceEntity? dailyAttendance,
  }) = _Success;

  const factory ParentDailyAttendanceState.emptyAttendance() =
      _EmptyAttendance;

  const factory ParentDailyAttendanceState.failure(Failure failure) = _Failure;
}
