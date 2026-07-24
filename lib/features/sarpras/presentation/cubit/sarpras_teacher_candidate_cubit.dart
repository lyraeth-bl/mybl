// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/sarpras_teacher_candidate/sarpras_teacher_candidate.dart';
import '../../domain/usecases/fetch_sarpras_teacher_candidate_use_case.dart';

part 'sarpras_teacher_candidate_state.dart';
part 'sarpras_teacher_candidate_cubit.freezed.dart';

class SarprasTeacherCandidateCubit extends Cubit<SarprasTeacherCandidateState> {
  SarprasTeacherCandidateCubit(this._fetchSarprasTeacherCandidateUseCase)
    : super(const .initial());

  final FetchSarprasTeacherCandidateUseCase
  _fetchSarprasTeacherCandidateUseCase;

  Future<void> fetchCandidates() async {
    emit(const .loading());

    final result = await _fetchSarprasTeacherCandidateUseCase();

    return result.match((f) => emit(.failure(f)), (r) {
      if (r.isEmpty) return emit(const .empty());

      emit(.success(candidates: r));
    });
  }
}
