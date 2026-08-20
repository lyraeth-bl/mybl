part of 'extracurricular_attendance_bloc.dart';

@freezed
sealed class ExtracurricularAttendanceEvent
    with _$ExtracurricularAttendanceEvent {
  const factory ExtracurricularAttendanceEvent.fetchExtracurricularAttendances() =
      _FetchExtracurricularAttendances;
}
