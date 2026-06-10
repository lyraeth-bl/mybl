import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/academic_calendar_entity.dart';

abstract class AcademicCalendarRepository
    implements AcademicCalendarFetcher<AcademicCalendarEntity> {}
