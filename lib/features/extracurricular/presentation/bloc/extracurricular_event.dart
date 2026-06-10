part of 'extracurricular_bloc.dart';

@freezed
sealed class ExtracurricularEvent with _$ExtracurricularEvent {
  const factory ExtracurricularEvent.fetchExtracurricular([
    @Default(false) bool forceRefresh,
  ]) = _FetchExtracurricular;
}
