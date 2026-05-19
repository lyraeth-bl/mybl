part of 'demerit_bloc.dart';

@freezed
sealed class DemeritEvent with _$DemeritEvent {
  const factory DemeritEvent.fetchDemerit({
    String? schoolSession,
    String? semester,
    @Default(false) bool forceRefresh,
  }) = _FetchDemerit;
}
