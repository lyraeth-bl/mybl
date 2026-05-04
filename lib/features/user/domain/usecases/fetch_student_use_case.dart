import '../../../../core/internal/src/types.dart';
import '../entities/student_entity/student_entity.dart';
import '../repositories/user_repository.dart';

class FetchStudentUseCase {
  FetchStudentUseCase(this._userRepository);

  final UserRepository _userRepository;

  Future<Result<StudentEntity>> call([bool forceRefresh = false]) =>
      _userRepository.fetch(forceRefresh);
}
