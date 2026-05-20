part of 'attendance_qr_bloc.dart';

@freezed
sealed class AttendanceQrEvent with _$AttendanceQrEvent {
  const factory AttendanceQrEvent.attendanceQrTokenRequested() =
      _AttendanceQrTokenRequested;
}
