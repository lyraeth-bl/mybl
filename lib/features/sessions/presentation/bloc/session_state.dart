part of 'session_bloc.dart';

@freezed
sealed class SessionState with _$SessionState {
  const factory SessionState.initial() = _Initial;

  const factory SessionState.loading() = _Loading;

  const factory SessionState.authenticated({required String accessToken}) =
      _Authenticated;

  const factory SessionState.unauthenticated() = _Unauthenticated;
}
