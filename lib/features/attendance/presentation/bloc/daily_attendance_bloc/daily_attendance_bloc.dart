// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/failure/failure.dart';
import '../../../../../core/internal/src/types.dart';
import '../../../domain/entities/attendance_entity/attendance_entity.dart';

part 'daily_attendance_bloc.freezed.dart';
part 'daily_attendance_event.dart';
part 'daily_attendance_state.dart';

/// Signature bersama antara [FetchDailyAttendanceUseCase] (student) dan
/// [FetchParentDailyAttendanceUseCase] (parent), supaya satu bloc & satu
/// screen bisa dipakai dua role tanpa duplikasi.
typedef DailyAttendanceFetcher =
    Future<Result<AttendanceEntity?>> Function([bool forceRefresh]);

class DailyAttendanceBloc
    extends Bloc<DailyAttendanceEvent, DailyAttendanceState> {
  DailyAttendanceBloc(this._fetchDailyAttendance)
    : super(const DailyAttendanceState.initial()) {
    on<_DailyAttendanceRequested>(_onDailyAttendanceRequested);
  }

  final DailyAttendanceFetcher _fetchDailyAttendance;

  Future<void> _onDailyAttendanceRequested(
    _DailyAttendanceRequested event,
    Emitter<DailyAttendanceState> emit,
  ) async {
    emit(const DailyAttendanceState.loading());

    final result = await _fetchDailyAttendance(event.forceRefresh);

    return result.match(
      (failure) => emit(DailyAttendanceState.failure(failure)),
      (data) {
        if (data == null) {
          emit(const DailyAttendanceState.emptyAttendance());
          return;
        }

        emit(DailyAttendanceState.success(dailyAttendance: data));
      },
    );
  }
}
