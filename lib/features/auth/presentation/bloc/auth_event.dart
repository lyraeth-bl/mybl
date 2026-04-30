part of 'auth_bloc.dart';

@freezed
<<<<<<< HEAD
sealed class AuthEvent with _$AuthEvent {
=======
abstract class AuthEvent with _$AuthEvent {
>>>>>>> 9c0b03c (feat(auth): implement bloc for login and logout functionality)
  const factory AuthEvent.loginRequested({required LoginParams loginParams}) =
      _LoginRequested;

  const factory AuthEvent.logoutRequested() = _LogoutRequested;
}
