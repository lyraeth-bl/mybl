// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/failure/failure.dart';
import '../../../domain/entities/discipline.dart';
import '../../../domain/usecases/fetch_demerit_use_case.dart';

part 'demerit_bloc.freezed.dart';
part 'demerit_event.dart';
part 'demerit_state.dart';

class DemeritBloc extends Bloc<DemeritEvent, DemeritState> {
  DemeritBloc(this._fetchDemeritUseCase) : super(const DemeritState.initial()) {
    on<_FetchDemerit>(_onFetchDemerit);
  }

  final FetchDemeritUseCase _fetchDemeritUseCase;

  Future<void> _onFetchDemerit(
    _FetchDemerit event,
    Emitter<DemeritState> emit,
  ) async {
    emit(const DemeritState.loading());

    final result = await _fetchDemeritUseCase(
      schoolSession: event.schoolSession,
      semester: event.semester,
      forceRefresh: event.forceRefresh,
    );

    return result.match((failure) => emit(DemeritState.failure(failure)), (
      data,
    ) {
      if (data == null) {
        emit(const DemeritState.emptyData());
        return;
      }

      emit(DemeritState.success(listDemerit: data));
    });
  }
}
