part of 'parent_bloc.dart';

@freezed
sealed class ParentState with _$ParentState {
  const factory ParentState.initial() = _Initial;

  const factory ParentState.loading() = _Loading;

  const factory ParentState.failure(Failure failure) = _Failure;

  const factory ParentState.ready({
    required ParentEntity parent,
    required List<ChildEntity> children,
    ChildEntity? selectedChild,
  }) = _Ready;
}
