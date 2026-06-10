part of 'remember_me_cubit.dart';

@freezed
sealed class RememberMeState with _$RememberMeState {
  const factory RememberMeState({
    @Default('') String savedNIS,
    @Default(false) bool isChecked,
  }) = _RememberMeState;
}
