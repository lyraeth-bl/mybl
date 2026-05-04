part of 'user_bloc.dart';

@freezed
sealed class UserState with _$UserState {
  const factory UserState.initial() = _Initial;

  const factory UserState.loading() = _Loading;

  const factory UserState.success({required StudentEntity student}) = _Success;

  const factory UserState.failure(Failure failure) = _Failure;
}
