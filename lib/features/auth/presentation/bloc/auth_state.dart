part of 'auth_bloc.dart';

@freezed
<<<<<<< HEAD
sealed class AuthState with _$AuthState {
=======
abstract class AuthState with _$AuthState {
>>>>>>> 9c0b03c (feat(auth): implement bloc for login and logout functionality)
  const factory AuthState.initial() = _Initial;

  const factory AuthState.loading() = _Loading;

  const factory AuthState.successLogin({
    required String accessToken,
    required DateTime expiresAt,
  }) = _SuccessLogin;

  const factory AuthState.successLogout() = _SuccessLogout;

  const factory AuthState.failure(Failure failure) = _Failure;
}
