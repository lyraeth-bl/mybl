part of 'daily_attendance_bloc.dart';

@freezed
sealed class DailyAttendanceState with _$DailyAttendanceState {
  const factory DailyAttendanceState.initial() = _Initial;

  const factory DailyAttendanceState.loading() = _Loading;

  const factory DailyAttendanceState.success({
    AttendanceEntity? dailyAttendance,
  }) = _Success;

  const factory DailyAttendanceState.emptyAttendance() = _EmptyAttendance;

  const factory DailyAttendanceState.failure(Failure failure) = _Failure;
}
