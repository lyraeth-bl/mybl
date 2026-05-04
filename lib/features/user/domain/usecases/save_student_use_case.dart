import 'package:fpdart/fpdart.dart';

import '../entities/student_entity/student_entity.dart';
import '../repositories/user_repository.dart';

class SaveStudentUseCase {
  SaveStudentUseCase(this._userRepository);

  final UserRepository _userRepository;

  Future<Unit> call(StudentEntity data) => _userRepository.save(data);
}
