import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/child_entity/child_entity.dart';
import '../../../domain/entities/parent_entity/parent_entity.dart';

part 'parent_bloc.freezed.dart';
part 'parent_event.dart';
part 'parent_state.dart';

class ParentBloc extends Bloc<ParentEvent, ParentState> {
  ParentBloc() : super(const ParentState.initial()) {
    on<_Initialized>(_onInitialized);
    on<_ChildSelected>(_onChildSelected);
  }

  void _onInitialized(_Initialized event, Emitter<ParentState> emit) {
    emit(ParentState.active(parent: event.parent));
  }

  void _onChildSelected(_ChildSelected event, Emitter<ParentState> emit) {
    final current = state;
    if (current is! _Active) return;

    emit(
      ParentState.active(
        parent: current.parent.copyWith(selectedChild: event.child),
      ),
    );
  }

  /// Helper — NIS aktif yang dipakai interceptor
  String? get activeNis {
    final current = state;

    final isActive = current.maybeWhen(
      active: (_) => true,
      orElse: () => false,
    );

    if (isActive) {
      return current.maybeWhen(
        active: (parent) => parent.activeNis,
        orElse: () => null,
      );
    }

    return null;
  }
}
