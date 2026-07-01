// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/failure/failure.dart';
import '../../../domain/entities/attendance_entity/attendance_entity.dart';
import '../../../domain/usecases/fetch_parent_daily_attendance_use_case.dart';

part 'parent_daily_attendance_bloc.freezed.dart';
part 'parent_daily_attendance_event.dart';
part 'parent_daily_attendance_state.dart';

class ParentDailyAttendanceBloc
    extends Bloc<ParentDailyAttendanceEvent, ParentDailyAttendanceState> {
  ParentDailyAttendanceBloc(this._fetchParentDailyAttendanceUseCase)
    : super(const ParentDailyAttendanceState.initial()) {
    on<_DailyAttendanceRequested>(_onDailyAttendanceRequested);
  }

  final FetchParentDailyAttendanceUseCase _fetchParentDailyAttendanceUseCase;

  Future<void> _onDailyAttendanceRequested(
    _DailyAttendanceRequested event,
    Emitter<ParentDailyAttendanceState> emit,
  ) async {
    emit(const ParentDailyAttendanceState.loading());

    final result = await _fetchParentDailyAttendanceUseCase(event.forceRefresh);

    return result.match(
      (failure) => emit(ParentDailyAttendanceState.failure(failure)),
      (data) {
        if (data == null) {
          emit(const ParentDailyAttendanceState.emptyAttendance());
          return;
        }

        emit(ParentDailyAttendanceState.success(dailyAttendance: data));
      },
    );
  }
}
