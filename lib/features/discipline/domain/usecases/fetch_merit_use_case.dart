// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/discipline.dart';
import '../repositories/repository.dart';

class FetchMeritUseCase {
  FetchMeritUseCase(this._disciplineRepository);

  final DisciplineRepository _disciplineRepository;

  Future<Result<List<MeritEntity>?>> call({
    String? schoolSession,
    String? semester,
    bool forceRefresh = false,
  }) => _disciplineRepository.fetchMerit(
    schoolSession: schoolSession,
    semester: semester,
    forceRefresh: forceRefresh,
  );
}
