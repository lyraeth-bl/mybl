import '../entities/student_entity/student_entity.dart';
import '../repositories/user_repository.dart';

class ReadStudentUseCase {
  ReadStudentUseCase(this._userRepository);

  final UserRepository _userRepository;

  StudentEntity? call() => _userRepository.read();
}
