import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/parent_response_entity/parent_response_entity.dart';

abstract class ParentAuthRepository
    implements Authenticator<ParentResponseEntity>, RememberMeStorage {}
