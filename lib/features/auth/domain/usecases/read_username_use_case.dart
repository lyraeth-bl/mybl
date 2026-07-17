// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../repositories/parent_auth_repository.dart';

class ReadUsernameUseCase {
  ReadUsernameUseCase(this._parentAuthRepository);

  final ParentAuthRepository _parentAuthRepository;

  Future<String?> call() => _parentAuthRepository.readUsername();
}
