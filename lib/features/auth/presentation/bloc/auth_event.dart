part of 'auth_bloc.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.loginRequested({
    required String nis,
    required String password,
  }) = _LoginRequested;

  const factory AuthEvent.logoutRequested() = _LogoutRequested;
}
