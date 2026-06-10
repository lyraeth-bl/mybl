// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../repositories/storage_repository.dart';

class ClearAllBoxesUseCase {
  ClearAllBoxesUseCase(this._storageRepository);

  final StorageRepository _storageRepository;

  Future<void> call() => _storageRepository.clearAllBoxes();
}
