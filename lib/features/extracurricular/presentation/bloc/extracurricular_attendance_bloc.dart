// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/extracurricular_attendance/extracurricular_attendance.dart';
import '../../domain/usecases/fetch_extracurricular_attendances_use_case.dart';

part 'extracurricular_attendance_bloc.freezed.dart';
part 'extracurricular_attendance_event.dart';
part 'extracurricular_attendance_state.dart';

class ExtracurricularAttendanceBloc
    extends
        Bloc<ExtracurricularAttendanceEvent, ExtracurricularAttendanceState> {
  ExtracurricularAttendanceBloc(this._fetchExtracurricularAttendancesUseCase)
    : super(const ExtracurricularAttendanceState.initial()) {
    on<_FetchExtracurricularAttendances>(_onFetchExtracurricularAttendances);
  }

  final FetchExtracurricularAttendancesUseCase
  _fetchExtracurricularAttendancesUseCase;

  Future<void> _onFetchExtracurricularAttendances(
    _FetchExtracurricularAttendances event,
    Emitter<ExtracurricularAttendanceState> emit,
  ) async {
    emit(const ExtracurricularAttendanceState.loading());

    final result = await _fetchExtracurricularAttendancesUseCase();

    return result.match(
      (failure) => emit(ExtracurricularAttendanceState.failure(failure)),
      (data) => emit(ExtracurricularAttendanceState.success(attendances: data)),
    );
  }
}
