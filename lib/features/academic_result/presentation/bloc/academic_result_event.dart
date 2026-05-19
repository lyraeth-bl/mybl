part of 'academic_result_bloc.dart';

@freezed
sealed class AcademicResultEvent with _$AcademicResultEvent {
  const factory AcademicResultEvent.fetchAcademicResult() =
      _FetchAcademicResult;
}
