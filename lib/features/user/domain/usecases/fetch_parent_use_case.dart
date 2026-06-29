// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/parent_entity/parent_entity.dart';
import '../repositories/parent_repository.dart';

class FetchParentUseCase {
  FetchParentUseCase(this._parentRepository);

  final ParentRepository _parentRepository;

  Future<Result<ParentEntity>> call({bool forceRefresh = false}) =>
      _parentRepository.fetchParent(forceRefresh: forceRefresh);
}
