// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../domain/entities/time_table/time_table.dart';
import '../../domain/usecases/fetch_time_table_use_case.dart';

part 'time_table_bloc.freezed.dart';
part 'time_table_event.dart';
part 'time_table_state.dart';

class TimeTableBloc extends Bloc<TimeTableEvent, TimeTableState> {
  TimeTableBloc(this._fetchTimeTableUseCase, this._userBloc)
    : super(const TimeTableState.initial()) {
    _userStreamSubscription = _userBloc.stream.listen((userState) {
      final String studentClass = userState.maybeWhen(
        success: (student) =>
            "${student.kelasSaatIni}${student.noKelasSaatIni}",
        orElse: () => "",
      );
      add(_FetchTimeTable(false, studentClass));
    });

    on<_FetchTimeTable>(_onFetchTimeTable);
  }

  final FetchTimeTableUseCase _fetchTimeTableUseCase;
  final UserBloc _userBloc;
  late final StreamSubscription _userStreamSubscription;

  Future<void> _onFetchTimeTable(
    _FetchTimeTable event,
    Emitter<TimeTableState> emit,
  ) async {
    emit(const TimeTableState.loading());

    final result = await _fetchTimeTableUseCase(
      event.forceRefresh,
      event.kelas,
    );

    return result.match(
      (failure) => emit(TimeTableState.failure(failure)),
      (data) => emit(TimeTableState.success(timeTable: data)),
    );
  }

  @override
  Future<void> close() {
    _userStreamSubscription.cancel();
    return super.close();
  }
}
