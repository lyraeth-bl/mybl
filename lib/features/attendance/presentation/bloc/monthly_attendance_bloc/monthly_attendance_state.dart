part of 'monthly_attendance_bloc.dart';

@freezed
sealed class MonthlyAttendanceState with _$MonthlyAttendanceState {
  const factory MonthlyAttendanceState.initial() = _Initial;

  const factory MonthlyAttendanceState.loading({
    required int month,
    required int year,
  }) = _Loading;

  const factory MonthlyAttendanceState.success({
    required int month,
    required int year,
    required List<AttendanceEntity> monthlyAttendance,
    required Map<DateTime, AttendanceStatus> attendanceMap,
    required Map<DateTime, AttendanceEntity> entityMap,
    required AttendanceSummary summary,
  }) = _Success;

  const factory MonthlyAttendanceState.failure(Failure failure) = _Failure;
}
