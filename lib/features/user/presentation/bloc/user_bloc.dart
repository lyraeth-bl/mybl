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

/// [UserBloc] itu "Pusat Kendali" buat semua hal yang berhubungan sama user di UI.
/// Dia dengerin apa yang lo mau (via [UserEvent]) dan ngasih tau UI harus
/// nampilin apa (via [UserState]).
///
/// Pokoknya UI gak boleh nembak Repository langsung, harus lewat jalur resmi
/// yaitu lewat si [UserBloc] ini.
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this._fetchStudentUseCase) : super(const UserState.initial()) {
    // Kalo ada yang minta fetch data siswa, kita jalanin fungsinya.
    on<_FetchStudentRequested>(_onFetchStudentRequested);
  }

  final FetchStudentUseCase _fetchStudentUseCase;

  /// Ini pawang buat kejadian `_FetchStudentRequested`.
  /// Alurnya: kasih tau UI lagi loading -> panggil kurir ([FetchStudentUseCase])
  /// -> kasih tau UI hasilnya (berhasil atau gagal).
  Future<void> _onFetchStudentRequested(
    _FetchStudentRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserState.loading());

    final result = await _fetchStudentUseCase(forceRefresh: event.forceRefresh);

    return result.match(
      (failure) => emit(UserState.failure(failure)),
      (data) => emit(UserState.success(student: data)),
    );
  }
}
