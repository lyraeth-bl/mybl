part of 'parent_monthly_attendance_bloc.dart';

@freezed
sealed class ParentMonthlyAttendanceState with _$ParentMonthlyAttendanceState {
  const factory ParentMonthlyAttendanceState.initial() = _Initial;

  const factory ParentMonthlyAttendanceState.loading({
    required int month,
    required int year,
  }) = _Loading;

  const factory ParentMonthlyAttendanceState.success({
    required int month,
    required int year,
    required List<AttendanceEntity> monthlyAttendance,
    required Map<DateTime, AttendanceStatus> attendanceMap,
    required Map<DateTime, AttendanceEntity> entityMap,
    required AttendanceSummary summary,
  }) = _Success;

  const factory ParentMonthlyAttendanceState.failure(Failure failure) =
      _Failure;
}
