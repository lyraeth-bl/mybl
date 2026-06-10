import '../../../../core/internal/src/types.dart';
import '../entities/academic_calendar_entity.dart';
import '../repositories/repository.dart';

class FetchAcademicCalendarUseCase {
  FetchAcademicCalendarUseCase(this._academicCalendarRepository);

  final AcademicCalendarRepository _academicCalendarRepository;

  Future<Result<List<AcademicCalendarEntity>?>> call({
    required int year,
    required int month,
    required String unit,
    bool forceRefresh = false,
  }) => _academicCalendarRepository.fetchAcademicCalendar(
    year: year,
    month: month,
    unit: unit,
    forceRefresh: forceRefresh,
  );
}
