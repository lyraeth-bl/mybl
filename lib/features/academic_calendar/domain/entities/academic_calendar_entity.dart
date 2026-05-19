import 'package:freezed_annotation/freezed_annotation.dart';

part 'academic_calendar_entity.freezed.dart';

@freezed
abstract class AcademicCalendarEntity with _$AcademicCalendarEntity {
  const factory AcademicCalendarEntity({
    required int id,
    required String judul,
    required String unit,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String keterangan,
  }) = _AcademicCalendarEntity;
}
