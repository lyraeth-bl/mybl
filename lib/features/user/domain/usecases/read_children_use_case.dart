// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/child_entity/child_entity.dart';
import '../repositories/parent_repository.dart';

class ReadChildrenUseCase {
  ReadChildrenUseCase(this._parentRepository);

  final ParentRepository _parentRepository;

  Future<Result<List<ChildEntity>>> call() => _parentRepository.readChildren();
}
