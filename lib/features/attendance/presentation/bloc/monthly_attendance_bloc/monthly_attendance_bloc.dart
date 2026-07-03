// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/failure/failure.dart';
import '../../../../../core/internal/src/types.dart';
import '../../../domain/entities/attendance_entity/attendance_entity.dart';
import '../../../domain/entities/attendance_status/attendance_status.dart';
import '../../../domain/entities/attendance_summary/attendance_summary.dart';

part 'monthly_attendance_bloc.freezed.dart';
part 'monthly_attendance_event.dart';
part 'monthly_attendance_state.dart';

/// Signature bersama antara [FetchMonthlyAttendanceUseCase] (student) dan
/// [FetchParentMonthlyAttendanceUseCase] (parent), supaya satu bloc & satu
/// screen bisa dipakai dua role tanpa duplikasi.
typedef MonthlyAttendanceFetcher =
    Future<Result<List<AttendanceEntity>>> Function({
      required int month,
      required int year,
      bool forceRefresh,
    });

/// Si paling sibuk ngurusin data absen bulanan.
///
/// BLoC ini tugasnya jadi jembatan antara UI sama [MonthlyAttendanceFetcher].
/// Dia yang tanggung jawab buat narik data, ngitung rangkuman (summary), sampe
/// ngerapiin data biar siap dipake sama widget Kalender atau Chart.
class MonthlyAttendanceBloc
    extends Bloc<MonthlyAttendanceEvent, MonthlyAttendanceState> {
  MonthlyAttendanceBloc(this._fetchMonthlyAttendance)
    : super(const MonthlyAttendanceState.initial()) {
    on<_MonthChangeRequested>(_onMonthChangeRequested);
    on<_PreviousMonthRequested>(_onPreviousMonthRequested);
    on<_NextMonthRequested>(_onNextMonthRequested);
  }

  final MonthlyAttendanceFetcher _fetchMonthlyAttendance;

  /// Helper buat nyari tau bulan ama tahun berapa yang lagi aktif di-track sama state.
  /// Kalo masih di initial state (awal banget), dia bakal balik ke bulan & tahun sekarang.
  (int month, int year) get _currentMonthYear {
    final s = state;
    return switch (s) {
      _Loading(:final month, :final year) => (month, year),
      _Success(:final month, :final year) => (month, year),
      _ => (DateTime.now().month, DateTime.now().year),
    };
  }

  /// Handler utama pas user mau ganti bulan.
  ///
  /// Dia bakal masang state loading dulu, terus manggil use case. Kalo berhasil,
  /// datanya nggak cuma disimpen mentah-mentah, tapi langsung diolah jadi Map buat Kalender
  /// ama object [AttendanceSummary] buat rangkuman angkanya.
  Future<void> _onMonthChangeRequested(
    _MonthChangeRequested event,
    Emitter<MonthlyAttendanceState> emit,
  ) async {
    emit(MonthlyAttendanceState.loading(month: event.month, year: event.year));

    final result = await _fetchMonthlyAttendance(
      month: event.month,
      year: event.year,
      forceRefresh: event.forceRefresh,
    );

    result.match((failure) => emit(MonthlyAttendanceState.failure(failure)), (
      data,
    ) {
      final attendanceMap = _toAttendanceMap(data);
      final entityMap = _toEntityMap(data);
      emit(
        MonthlyAttendanceState.success(
          month: event.month,
          year: event.year,
          monthlyAttendance: data,
          attendanceMap: attendanceMap,
          entityMap: entityMap,
          summary: _toSummary(attendanceMap, event.month, event.year),
        ),
      );
    });
  }

  /// Shortcut buat mundurin kalender ke bulan sebelumnya.
  /// Dia bakal ngitung sendiri transisi tahun kalo lagi di bulan Januari.
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

  /// Shortcut buat majuin kalender ke bulan berikutnya.
  /// Pinter juga buat handle ganti tahun pas lagi di bulan Desember.
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

  /// Tukang sortir data. Ngubah list [AttendanceEntity] jadi Map biar gampang
  /// dicari berdasarkan tanggal pas mau ditampilin di Kalender.
  ///
  /// Mapping status dari API:
  /// - "Hadir" -> [AttendanceStatus.present]
  /// - "Terlambat" -> [AttendanceStatus.late]
  /// - "Belum Check-In" -> [AttendanceStatus.absent]
  /// - Sisanya anggep aja Izin/Excused.
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

  /// Helper buat ngitung berapa banyak hari kerja (Senin-Jumat) yang udah lewat.
  /// Kalo bulan yang diliat itu bulan sekarang, dia cuma ngitung sampe hari ini.
  /// Kalo bulan lama, ya dihitung semua hari kerjanya.
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

  /// Tukang rekap. Ngitung total hadir, telat, izin, ama alpa dari Map absen,
  /// terus dibungkus jadi [AttendanceSummary].
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

  /// Nyimpen data entity utuh ke dalem Map biar pas user klik tanggal di kalender,
  /// kita bisa langsung tarik detail datanya tanpa cari-cari lagi di list.
  static Map<DateTime, AttendanceEntity> _toEntityMap(
    List<AttendanceEntity> list,
  ) {
    return {
      for (final e in list)
        DateTime(e.tanggal.year, e.tanggal.month, e.tanggal.day): e,
    };
  }
}
