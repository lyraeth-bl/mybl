// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/academic_result/academic_result.dart';
import '../repositories/repository.dart';

class FetchAcademicResultUseCase {
  FetchAcademicResultUseCase(this._academicResultRepository);

  final AcademicResultRepository _academicResultRepository;

  Future<Result<AcademicResultResponse>> call([bool forceRefresh = false]) =>
      _academicResultRepository.fetch(forceRefresh);
}
