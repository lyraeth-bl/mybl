// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/student_entity/student_entity.dart';
import '../../domain/usecases/fetch_student_use_case.dart';

part 'user_bloc.freezed.dart';
part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this._fetchStudentUseCase) : super(const UserState.initial()) {
    on<_FetchStudentRequested>(_onFetchStudentRequested);
  }

  final FetchStudentUseCase _fetchStudentUseCase;

  Future<void> _onFetchStudentRequested(
    _FetchStudentRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserState.loading());

    final result = await _fetchStudentUseCase(event.forceRefresh);

    return result.match(
      (failure) => emit(UserState.failure(failure)),
      (data) => emit(UserState.success(student: data)),
    );
  }
}
