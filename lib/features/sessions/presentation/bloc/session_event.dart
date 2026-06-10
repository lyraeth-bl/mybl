part of 'session_bloc.dart';

@freezed
sealed class SessionEvent with _$SessionEvent {
  const factory SessionEvent.started() = _Started;

  const factory SessionEvent.loggedIn({
    required String accessToken,
    required DateTime expiresAt,
  }) = _LoggedIn;

  const factory SessionEvent.loggedOut() = _LoggedOut;
}
