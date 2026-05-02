part of 'auth_bloc.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;

  const factory AuthState.loading() = _Loading;

  const factory AuthState.successLogin({
    required String accessToken,
    required DateTime expiresAt,
  }) = _SuccessLogin;

  const factory AuthState.successLogout() = _SuccessLogout;

  const factory AuthState.failure(Failure failure) = _Failure;
}
