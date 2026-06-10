// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/extracurricular.dart';
import '../../domain/usecases/fetch_extracurricular_use_case.dart';

part 'extracurricular_bloc.freezed.dart';
part 'extracurricular_event.dart';
part 'extracurricular_state.dart';

class ExtracurricularBloc
    extends Bloc<ExtracurricularEvent, ExtracurricularState> {
  ExtracurricularBloc(this._fetchExtracurricularUseCase)
    : super(const ExtracurricularState.initial()) {
    on<_FetchExtracurricular>(_onFetchExtracurricular);
  }

  final FetchExtracurricularUseCase _fetchExtracurricularUseCase;

  Future<void> _onFetchExtracurricular(
    _FetchExtracurricular event,
    Emitter<ExtracurricularState> emit,
  ) async {
    emit(const ExtracurricularState.loading());

    final result = await _fetchExtracurricularUseCase(event.forceRefresh);

    return result.match(
      (failure) => emit(ExtracurricularState.failure(failure)),
      (data) => emit(ExtracurricularState.success(extracurricular: data)),
    );
  }
}
