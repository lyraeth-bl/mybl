// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/internal/src/types.dart';
import '../repositories/sarpras_repository.dart';

class DestroySarprasUseCase {
  DestroySarprasUseCase(this._sarprasRepository);

  final SarprasRepository _sarprasRepository;

  Future<Result<Unit>> call({required int sarprasId}) =>
      _sarprasRepository.destroySarpras(sarprasId: sarprasId);
}
