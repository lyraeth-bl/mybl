import '../../../../core/internal/internal.dart';
import '../entities/parent_response_entity/parent_response_entity.dart';
import '../repositories/parent_auth_repository.dart';

class LoginParentUseCase {
  LoginParentUseCase(this._parentAuthRepository);

  final ParentAuthRepository _parentAuthRepository;

  Future<Result<ParentResponseEntity>> call({
    required String nis,
    required String password,
  }) => _parentAuthRepository.login(nis: nis, password: password);
}
