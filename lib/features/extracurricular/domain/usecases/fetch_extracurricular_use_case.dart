// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/extracurricular.dart';
import '../repositories/repository.dart';

class FetchExtracurricularUseCase {
  FetchExtracurricularUseCase(this._extracurricularRepository);

  final ExtracurricularRepository _extracurricularRepository;

  Future<Result<List<ExtracurricularEntity>>> call([
    bool forceRefresh = false,
  ]) => _extracurricularRepository.fetchAll(forceRefresh);
}
