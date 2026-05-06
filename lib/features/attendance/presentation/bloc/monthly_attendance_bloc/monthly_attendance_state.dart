part of 'monthly_attendance_bloc.dart';

@freezed
sealed class MonthlyAttendanceState with _$MonthlyAttendanceState {
  const factory MonthlyAttendanceState.initial() = _Initial;

  const factory MonthlyAttendanceState.loading() = _Loading;

  const factory MonthlyAttendanceState.success({
    required int month,
    required int year,
    required List<AttendanceEntity> monthlyAttendance,
  }) = _Success;

  const factory MonthlyAttendanceState.failure(Failure failure) = _Failure;
}
