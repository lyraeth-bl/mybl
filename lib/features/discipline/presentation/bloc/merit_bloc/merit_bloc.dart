// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/failure/failure.dart';
import '../../../domain/entities/discipline.dart';
import '../../../domain/usecases/fetch_merit_use_case.dart';

part 'merit_bloc.freezed.dart';
part 'merit_event.dart';
part 'merit_state.dart';

class MeritBloc extends Bloc<MeritEvent, MeritState> {
  MeritBloc(this._fetchMeritUseCase) : super(const MeritState.initial()) {
    on<_FetchMerit>(_onFetchMerit);
  }

  final FetchMeritUseCase _fetchMeritUseCase;

  Future<void> _onFetchMerit(
    _FetchMerit event,
    Emitter<MeritState> emit,
  ) async {
    emit(const MeritState.loading());

    final result = await _fetchMeritUseCase(
      schoolSession: event.schoolSession,
      semester: event.semester,
      forceRefresh: event.forceRefresh,
    );

    return result.match((failure) => emit(MeritState.failure(failure)), (data) {
      if (data == null) {
        emit(const MeritState.emptyData());
        return;
      }

      emit(MeritState.success(listMerit: data));
    });
  }
}
