// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/failure/failure.dart';
import '../../../domain/entities/attendance_entity/attendance_entity.dart';
import '../../../domain/entities/attendance_status/attendance_status.dart';
import '../../../domain/entities/attendance_summary/attendance_summary.dart';
import '../../../domain/usecases/fetch_parent_monthly_attendance_use_case.dart';

part 'parent_monthly_attendance_bloc.freezed.dart';
part 'parent_monthly_attendance_event.dart';
part 'parent_monthly_attendance_state.dart';

class ParentMonthlyAttendanceBloc
    extends
        Bloc<ParentMonthlyAttendanceEvent, ParentMonthlyAttendanceState> {
  ParentMonthlyAttendanceBloc(this._fetchParentMonthlyAttendanceUseCase)
    : super(const ParentMonthlyAttendanceState.initial()) {
    on<_MonthChangeRequested>(_onMonthChangeRequested);
    on<_PreviousMonthRequested>(_onPreviousMonthRequested);
    on<_NextMonthRequested>(_onNextMonthRequested);
  }

  final FetchParentMonthlyAttendanceUseCase _fetchParentMonthlyAttendanceUseCase;

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
    Emitter<ParentMonthlyAttendanceState> emit,
  ) async {
    emit(
      ParentMonthlyAttendanceState.loading(
        month: event.month,
        year: event.year,
      ),
    );

    final result = await _fetchParentMonthlyAttendanceUseCase(
      month: event.month,
      year: event.year,
      forceRefresh: event.forceRefresh,
    );

    result.match(
      (failure) => emit(ParentMonthlyAttendanceState.failure(failure)),
      (data) {
        final attendanceMap = _toAttendanceMap(data);
        final entityMap = _toEntityMap(data);
        emit(
          ParentMonthlyAttendanceState.success(
            month: event.month,
            year: event.year,
            monthlyAttendance: data,
            attendanceMap: attendanceMap,
            entityMap: entityMap,
            summary: _toSummary(attendanceMap, event.month, event.year),
          ),
        );
      },
    );
  }

  Future<void> _onPreviousMonthRequested(
    _PreviousMonthRequested event,
    Emitter<ParentMonthlyAttendanceState> emit,
  ) async {
    final (month, year) = _currentMonthYear;
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    add(
      ParentMonthlyAttendanceEvent.monthChangeRequested(
        month: prevMonth,
        year: prevYear,
      ),
    );
  }

  Future<void> _onNextMonthRequested(
    _NextMonthRequested event,
    Emitter<ParentMonthlyAttendanceState> emit,
  ) async {
    final (month, year) = _currentMonthYear;
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    add(
      ParentMonthlyAttendanceEvent.monthChangeRequested(
        month: nextMonth,
        year: nextYear,
      ),
    );
  }

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

  static int _countWorkingDaysElapsed(int month, int year) {
    final now = DateTime.now();
    final isCurrentMonth = month == now.month && year == now.year;
    final lastDay = isCurrentMonth
        ? now.day
        : DateUtils.getDaysInMonth(year, month);

    int count = 0;
    for (int day = 1; day <= lastDay; day++) {
      final weekday = DateTime(year, month, day).weekday;
      if (weekday != DateTime.saturday && weekday != DateTime.sunday) {
        count++;
      }
    }
    return count;
  }

  static AttendanceSummary _toSummary(
    Map<DateTime, AttendanceStatus> attendanceMap,
    int month,
    int year,
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
      workingDaysElapsed: _countWorkingDaysElapsed(month, year),
    );
  }

  static Map<DateTime, AttendanceEntity> _toEntityMap(
    List<AttendanceEntity> list,
  ) {
    return {
      for (final e in list)
        DateTime(e.tanggal.year, e.tanggal.month, e.tanggal.day): e,
    };
  }
}
