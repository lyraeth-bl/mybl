// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/failure/failure.dart';
import '../../../domain/entities/attendance_entity/attendance_entity.dart';
import '../../../domain/usecases/fetch_monthly_attendance_use_case.dart';

part 'monthly_attendance_bloc.freezed.dart';
part 'monthly_attendance_event.dart';
part 'monthly_attendance_state.dart';

class MonthlyAttendanceBloc
    extends Bloc<MonthlyAttendanceEvent, MonthlyAttendanceState> {
  MonthlyAttendanceBloc(this._monthlyAttendanceUseCase)
    : super(const MonthlyAttendanceState.initial()) {
    on<_MonthChangeRequested>(_onMonthChangeRequested);
  }

  final FetchMonthlyAttendanceUseCase _monthlyAttendanceUseCase;

  Future<void> _onMonthChangeRequested(
    _MonthChangeRequested event,
    Emitter<MonthlyAttendanceState> emit,
  ) async {
    emit(const MonthlyAttendanceState.loading());

    final result = await _monthlyAttendanceUseCase(
      month: event.month,
      year: event.year,
      forceRefresh: event.forceRefresh,
    );

    return result.match(
      (failure) => emit(MonthlyAttendanceState.failure(failure)),
      (data) => emit(
        MonthlyAttendanceState.success(
          month: event.month,
          year: event.year,
          monthlyAttendance: data,
        ),
      ),
    );
  }
}
