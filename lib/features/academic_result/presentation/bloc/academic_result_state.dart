part of 'academic_result_bloc.dart';

@freezed
sealed class AcademicResultState with _$AcademicResultState {
  const factory AcademicResultState.initial() = _Initial;

  const factory AcademicResultState.loading() = _Loading;

  const factory AcademicResultState.success({
    required AcademicResultResponse academicResult,
  }) = _Success;

  const factory AcademicResultState.failure(Failure failure) = _Failure;
}
