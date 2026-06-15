part of 'parent_bloc.dart';

@freezed
sealed class ParentEvent with _$ParentEvent {
  const factory ParentEvent.initialized(ParentEntity parent) = _Initialized;

  const factory ParentEvent.childSelected(ChildEntity child) = _ChildSelected;
}
