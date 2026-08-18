part of 'detail_extracurricular_attendance_cubit.dart';

@freezed
sealed class DetailExtracurricularAttendanceState
    with _$DetailExtracurricularAttendanceState {
  const factory DetailExtracurricularAttendanceState.initial() = _Initial;

  const factory DetailExtracurricularAttendanceState.loading() = _Loading;

  const factory DetailExtracurricularAttendanceState.success({
    required ExtracurricularAttendanceDetail attendance,
  }) = _Success;

  const factory DetailExtracurricularAttendanceState.failure(Failure failure) =
      _Failure;
}
