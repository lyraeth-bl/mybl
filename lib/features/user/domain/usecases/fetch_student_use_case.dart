// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/types.dart';
import '../entities/student_entity/student_entity.dart';
import '../repositories/user_repository.dart';

class FetchStudentUseCase {
  FetchStudentUseCase(this._userRepository);

  final UserRepository _userRepository;

  Future<Result<StudentEntity>> call({bool forceRefresh = false}) =>
      _userRepository.fetch(forceRefresh: forceRefresh);
}
