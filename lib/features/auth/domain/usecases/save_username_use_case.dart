// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../repositories/parent_auth_repository.dart';

class SaveUsernameUseCase {
  SaveUsernameUseCase(this._parentAuthRepository);

  final ParentAuthRepository _parentAuthRepository;

  Future<Unit> call(String username) =>
      _parentAuthRepository.saveUsername(username);
}
