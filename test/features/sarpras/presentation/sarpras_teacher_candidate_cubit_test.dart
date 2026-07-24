// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras_teacher_candidate/sarpras_teacher_candidate.dart';
import 'package:my_bl/features/sarpras/domain/repositories/sarpras_repository.dart';
import 'package:my_bl/features/sarpras/domain/usecases/fetch_sarpras_teacher_candidate_use_case.dart';
import 'package:my_bl/features/sarpras/presentation/cubit/sarpras_teacher_candidate_cubit.dart';

class _MockSarprasRepository extends Mock implements SarprasRepository {}

const SarprasTeacherCandidate _teacher = SarprasTeacherCandidate(
  nip: '20250602',
  name: 'Budi Santoso',
);

void main() {
  test('emits success when candidates exist', () async {
    final repository = _MockSarprasRepository();
    when(
      () => repository.fetchSarprasTeacherCandidate(),
    ).thenAnswer((_) async => right([_teacher]));

    final cubit = SarprasTeacherCandidateCubit(
      FetchSarprasTeacherCandidateUseCase(repository),
    );
    addTearDown(cubit.close);

    final states = <SarprasTeacherCandidateState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.fetchCandidates();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(states, [
      const SarprasTeacherCandidateState.loading(),
      const SarprasTeacherCandidateState.success(candidates: [_teacher]),
    ]);
  });

  test('emits empty when the candidate list is empty', () async {
    final repository = _MockSarprasRepository();
    when(
      () => repository.fetchSarprasTeacherCandidate(),
    ).thenAnswer((_) async => right(<SarprasTeacherCandidate>[]));

    final cubit = SarprasTeacherCandidateCubit(
      FetchSarprasTeacherCandidateUseCase(repository),
    );
    addTearDown(cubit.close);

    final states = <SarprasTeacherCandidateState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.fetchCandidates();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(states, [
      const SarprasTeacherCandidateState.loading(),
      const SarprasTeacherCandidateState.empty(),
    ]);
  });
}
