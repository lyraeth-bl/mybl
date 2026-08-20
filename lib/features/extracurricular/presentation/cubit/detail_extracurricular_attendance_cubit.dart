// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/extracurricular_attendance/extracurricular_attendance.dart';
import '../../domain/usecases/fetch_extracurricular_attendance_detail_use_case.dart';

part 'detail_extracurricular_attendance_state.dart';
part 'detail_extracurricular_attendance_cubit.freezed.dart';

class DetailExtracurricularAttendanceCubit
    extends Cubit<DetailExtracurricularAttendanceState> {
  DetailExtracurricularAttendanceCubit(
    this._fetchExtracurricularAttendancesDetailUseCase,
  ) : super(const .initial());

  final FetchExtracurricularAttendancesDetailUseCase
  _fetchExtracurricularAttendancesDetailUseCase;

  Future<void> fetchDetail({required int extraSessionId}) async {
    emit(const .loading());

    final result = await _fetchExtracurricularAttendancesDetailUseCase(
      extraSessionId: extraSessionId,
    );

    return result.match(
      (f) => emit(.failure(f)),
      (r) => emit(.success(attendance: r)),
    );
  }
}
