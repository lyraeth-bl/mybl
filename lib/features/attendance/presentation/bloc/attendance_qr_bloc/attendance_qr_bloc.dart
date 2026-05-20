// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/failure/failure.dart';
import '../../../domain/entities/attendance_qr_token/attendance_qr_token.dart';
import '../../../domain/usecases/fetch_attendance_qr_token_use_case.dart';

part 'attendance_qr_bloc.freezed.dart';
part 'attendance_qr_event.dart';
part 'attendance_qr_state.dart';

class AttendanceQrBloc extends Bloc<AttendanceQrEvent, AttendanceQrState> {
  AttendanceQrBloc(this._fetchAttendanceQrTokenUseCase)
    : super(const AttendanceQrState.initial()) {
    on<_AttendanceQrTokenRequested>(_onAttendanceQrTokenRequested);
  }

  final FetchAttendanceQrTokenUseCase _fetchAttendanceQrTokenUseCase;

  Future<void> _onAttendanceQrTokenRequested(
    _AttendanceQrTokenRequested event,
    Emitter<AttendanceQrState> emit,
  ) async {
    final currentQrToken = state.maybeWhen(
      loading: (qrToken) => qrToken,
      success: (qrToken) => qrToken,
      orElse: () => null,
    );

    emit(AttendanceQrState.loading(qrToken: currentQrToken));

    final result = await _fetchAttendanceQrTokenUseCase();

    return result.match(
      (failure) => emit(AttendanceQrState.failure(failure)),
      (qrToken) => emit(AttendanceQrState.success(qrToken: qrToken)),
    );
  }
}
