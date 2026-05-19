part of 'merit_bloc.dart';

@freezed
sealed class MeritEvent with _$MeritEvent {
  const factory MeritEvent.fetchMerit({
    String? schoolSession,
    String? semester,
    @Default(false) bool forceRefresh,
  }) = _FetchMerit;
}
