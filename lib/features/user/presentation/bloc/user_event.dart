part of 'user_bloc.dart';

@freezed
sealed class UserEvent with _$UserEvent {
  const factory UserEvent.fetchStudentRequested([
    @Default(false) bool forceRefresh,
  ]) = _FetchStudentRequested;
}
