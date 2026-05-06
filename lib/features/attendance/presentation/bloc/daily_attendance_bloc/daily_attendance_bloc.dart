// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/failure/failure.dart';
import '../../../domain/entities/attendance_entity/attendance_entity.dart';
import '../../../domain/usecases/fetch_daily_attendance_use_case.dart';

part 'daily_attendance_bloc.freezed.dart';
part 'daily_attendance_event.dart';
part 'daily_attendance_state.dart';

class DailyAttendanceBloc
    extends Bloc<DailyAttendanceEvent, DailyAttendanceState> {
  DailyAttendanceBloc(this._dailyAttendanceUseCase)
    : super(const DailyAttendanceState.initial()) {
    on<_DailyAttendanceRequested>(_onDailyAttendanceRequested);
  }

  final FetchDailyAttendanceUseCase _dailyAttendanceUseCase;

  Future<void> _onDailyAttendanceRequested(
    _DailyAttendanceRequested event,
    Emitter<DailyAttendanceState> emit,
  ) async {
    emit(const DailyAttendanceState.loading());

    final result = await _dailyAttendanceUseCase(event.forceRefresh);

    return result.match(
      (failure) => emit(DailyAttendanceState.failure(failure)),
      (data) {
        if (data == null) emit(const DailyAttendanceState.emptyAttendance());

        emit(DailyAttendanceState.success(dailyAttendance: data));
      },
    );
  }
}
