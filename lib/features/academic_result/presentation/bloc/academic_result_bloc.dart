// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/academic_result/academic_result.dart';
import '../../domain/usecases/fetch_academic_result_use_case.dart';

part 'academic_result_bloc.freezed.dart';
part 'academic_result_event.dart';
part 'academic_result_state.dart';

class AcademicResultBloc
    extends Bloc<AcademicResultEvent, AcademicResultState> {
  AcademicResultBloc(this._academicResultUseCase)
    : super(const AcademicResultState.initial()) {
    on<_FetchAcademicResult>(_onFetchAcademicResult);
  }

  final FetchAcademicResultUseCase _academicResultUseCase;

  Future<void> _onFetchAcademicResult(
    _FetchAcademicResult event,
    Emitter<AcademicResultState> emit,
  ) async {
    emit(const AcademicResultState.loading());

    final result = await _academicResultUseCase();

    return result.match(
      (failure) => emit(AcademicResultState.failure(failure)),
      (result) => emit(AcademicResultState.success(academicResult: result)),
    );
  }
}
