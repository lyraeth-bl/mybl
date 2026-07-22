part of 'sarpras_bloc.dart';

@freezed
sealed class SarprasEvent with _$SarprasEvent {
  const factory SarprasEvent.fetchSarpras() = _FetchSarpras;
}
