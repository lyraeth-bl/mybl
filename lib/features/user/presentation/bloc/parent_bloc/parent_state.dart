part of 'parent_bloc.dart';

@freezed
sealed class ParentState with _$ParentState {
  const factory ParentState.initial() = _Initial;

  const factory ParentState.active({required ParentEntity parent}) = _Active;
}
