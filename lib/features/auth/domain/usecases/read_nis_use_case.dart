// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../repositories/auth_repository.dart';

class ReadNisUseCase {
  ReadNisUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<String?> call() => _authRepository.readNIS();
}
