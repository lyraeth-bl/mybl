import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/academic_calendar_entity.dart';
import '../../domain/usecases/fetch_academic_calendar_use_case.dart';

part 'academic_calendar_bloc.freezed.dart';
part 'academic_calendar_event.dart';
part 'academic_calendar_state.dart';

class AcademicCalendarBloc
    extends Bloc<AcademicCalendarEvent, AcademicCalendarState> {
  AcademicCalendarBloc(this._academicCalendarUseCase)
    : super(const AcademicCalendarState.initial()) {
    on<_FetchAcademicCalendar>(_onFetchAcademicCalendar);
  }

  final FetchAcademicCalendarUseCase _academicCalendarUseCase;

  Future<void> _onFetchAcademicCalendar(
    _FetchAcademicCalendar event,
    Emitter<AcademicCalendarState> emit,
  ) async {
    emit(const AcademicCalendarState.loading());

    final result = await _academicCalendarUseCase(
      year: event.year,
      month: event.month,
      unit: event.unit,
      forceRefresh: event.forceRefresh,
    );

    return result.match(
      (failure) => emit(AcademicCalendarState.failure(failure)),
      (data) {
        if (data == null) {
          emit(const AcademicCalendarState.emptyData());
          return;
        }

        emit(
          AcademicCalendarState.success(
            academicCalendar: data,
            year: event.year,
            month: event.month,
          ),
        );
      },
    );
  }
}
