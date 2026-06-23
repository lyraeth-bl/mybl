// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/internal/src/types.dart';
import '../entities/child_entity/child_entity.dart';
import '../repositories/parent_repository.dart';

class SaveChildrenUseCase {
  SaveChildrenUseCase(this._parentRepository);

  final ParentRepository _parentRepository;

  Future<Result<Unit>> call(List<ChildEntity> children) =>
      _parentRepository.saveChildren(children);
}
