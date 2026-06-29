// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/child_entity/child_entity.dart';
import '../entities/parent_entity/parent_entity.dart';

abstract class ParentRepository
    implements ParentFetcher<ParentEntity>, ParentChildManager<ChildEntity> {}
