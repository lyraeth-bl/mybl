// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/sarpras/sarpras.dart';
import '../entities/sarpras_params/sarpras_params.dart';
import '../repositories/sarpras_repository.dart';

class StoreSarprasUseCase {
  StoreSarprasUseCase(this._sarprasRepository);

  final SarprasRepository _sarprasRepository;

  Future<Result<Sarpras>> call(SarprasParams params) =>
      _sarprasRepository.storeSarpras(params);
}
