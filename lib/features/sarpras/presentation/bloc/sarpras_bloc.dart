// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/sarpras/sarpras.dart';
import '../../domain/entities/sarpras_summary/sarpras_summary.dart';
import '../../domain/usecases/fetch_sarpras_use_case.dart';

part 'sarpras_event.dart';
part 'sarpras_state.dart';
part 'sarpras_bloc.freezed.dart';

class SarprasBloc extends Bloc<SarprasEvent, SarprasState> {
  SarprasBloc(this._fetchSarprasUseCase) : super(const .initial()) {
    on<_FetchSarpras>(_onFetchSarpras);
  }

  final FetchSarprasUseCase _fetchSarprasUseCase;

  Future<void> _onFetchSarpras(
    _FetchSarpras event,
    Emitter<SarprasState> emit,
  ) async {
    emit(const .loading());

    final result = await _fetchSarprasUseCase();

    return result.match((f) => emit(.failure(f)), (r) {
      final SarprasSummary summary = r.$1;
      final List<Sarpras> listSarpras = r.$2;

      if (listSarpras.isEmpty) {
        return emit(.empty(summary: summary));
      }

      emit(.success(summary: summary, listSarpras: listSarpras));
    });
  }
}
