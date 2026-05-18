part of 'time_table_bloc.dart';

@freezed
sealed class TimeTableEvent with _$TimeTableEvent {
  const factory TimeTableEvent.fetchTimeTable([
    @Default(false) bool forceRefresh,
    @Default("") String kelas,
  ]) = _FetchTimeTable;
}
