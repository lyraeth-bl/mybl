import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/student_entity/student_entity.dart';

abstract class UserRepository
    implements ItemFetcher<StudentEntity>, CacheStorage<StudentEntity> {}
