part of 'attendance_qr_bloc.dart';

@freezed
sealed class AttendanceQrState with _$AttendanceQrState {
  const factory AttendanceQrState.initial() = _Initial;

  const factory AttendanceQrState.loading({AttendanceQrToken? qrToken}) =
      _Loading;

  const factory AttendanceQrState.success({
    required AttendanceQrToken qrToken,
  }) = _Success;

  const factory AttendanceQrState.failure(Failure failure) = _Failure;
}
