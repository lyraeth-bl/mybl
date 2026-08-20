part of 'extracurricular_attendance_bloc.dart';

@freezed
sealed class ExtracurricularAttendanceState
    with _$ExtracurricularAttendanceState {
  const factory ExtracurricularAttendanceState.initial() = _Initial;

  const factory ExtracurricularAttendanceState.loading() = _Loading;

  const factory ExtracurricularAttendanceState.success({
    required List<ExtracurricularAttendance> attendances,
  }) = _Success;

  const factory ExtracurricularAttendanceState.failure(Failure failure) =
      _Failure;
}
