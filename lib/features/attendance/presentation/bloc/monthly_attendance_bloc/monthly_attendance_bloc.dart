// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/failure/failure.dart';
import '../../../domain/entities/attendance_entity/attendance_entity.dart';
import '../../../domain/entities/attendance_status/attendance_status.dart';
import '../../../domain/entities/attendance_summary/attendance_summary.dart';
import '../../../domain/usecases/fetch_monthly_attendance_use_case.dart';

part 'monthly_attendance_bloc.freezed.dart';
part 'monthly_attendance_event.dart';
part 'monthly_attendance_state.dart';

class MonthlyAttendanceBloc
    extends Bloc<MonthlyAttendanceEvent, MonthlyAttendanceState> {
  MonthlyAttendanceBloc(this._monthlyAttendanceUseCase)
    : super(const MonthlyAttendanceState.initial()) {
    on<_MonthChangeRequested>(_onMonthChangeRequested);
    on<_PreviousMonthRequested>(_onPreviousMonthRequested);
    on<_NextMonthRequested>(_onNextMonthRequested);
  }

  final FetchMonthlyAttendanceUseCase _monthlyAttendanceUseCase;

  /// Returns the current (month, year) tracked by the state.
  /// Falls back to now if still in the initial state.
  (int month, int year) get _currentMonthYear {
    final s = state;
    return switch (s) {
      _Loading(:final month, :final year) => (month, year),
      _Success(:final month, :final year) => (month, year),
      _ => (DateTime.now().month, DateTime.now().year),
    };
  }

  Future<void> _onMonthChangeRequested(
    _MonthChangeRequested event,
    Emitter<MonthlyAttendanceState> emit,
  ) async {
    emit(MonthlyAttendanceState.loading(month: event.month, year: event.year));

    final result = await _monthlyAttendanceUseCase(
      month: event.month,
      year: event.year,
      forceRefresh: event.forceRefresh,
    );

    result.match((failure) => emit(MonthlyAttendanceState.failure(failure)), (
      data,
    ) {
      final attendanceMap = _toAttendanceMap(data);
      emit(
        MonthlyAttendanceState.success(
          month: event.month,
          year: event.year,
          monthlyAttendance: data,
          attendanceMap: attendanceMap,
          summary: _toSummary(attendanceMap),
        ),
      );
    });
  }

  Future<void> _onPreviousMonthRequested(
    _PreviousMonthRequested event,
    Emitter<MonthlyAttendanceState> emit,
  ) async {
    final (month, year) = _currentMonthYear;
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    add(
      MonthlyAttendanceEvent.monthChangeRequested(
        month: prevMonth,
        year: prevYear,
      ),
    );
  }

  Future<void> _onNextMonthRequested(
    _NextMonthRequested event,
    Emitter<MonthlyAttendanceState> emit,
  ) async {
    final (month, year) = _currentMonthYear;
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    add(
      MonthlyAttendanceEvent.monthChangeRequested(
        month: nextMonth,
        year: nextYear,
      ),
    );
  }

  /// Converts a list of [AttendanceEntity] into a map keyed by normalized date.
  ///
  /// API status values:
  ///   "Hadir"         → [AttendanceStatus.present]
  ///   "Terlambat"     → [AttendanceStatus.late]
  ///   "Belum Check-In"→ [AttendanceStatus.absent]
  ///   anything else   → [AttendanceStatus.excused]
  static Map<DateTime, AttendanceStatus> _toAttendanceMap(
    List<AttendanceEntity> list,
  ) {
    return {
      for (final e in list)
        DateTime(
          e.tanggal.year,
          e.tanggal.month,
          e.tanggal.day,
        ): switch (e.status) {
          'Hadir' => AttendanceStatus.present,
          'Terlambat' => AttendanceStatus.late,
          'Belum Check-In' => AttendanceStatus.absent,
          _ => AttendanceStatus.excused,
        },
    };
  }

  static AttendanceSummary _toSummary(
    Map<DateTime, AttendanceStatus> attendanceMap,
  ) {
    int present = 0, late = 0, excused = 0, absent = 0;

    for (final status in attendanceMap.values) {
      switch (status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.late:
          late++;
        case AttendanceStatus.excused:
          excused++;
        case AttendanceStatus.absent:
          absent++;
      }
    }

    return AttendanceSummary(
      present: present,
      late: late,
      excused: excused,
      absent: absent,
    );
  }
}
