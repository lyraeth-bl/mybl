import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/academic_calendar_entity.dart';

part 'academic_calendar_model.freezed.dart';
part 'academic_calendar_model.g.dart';

@freezed
abstract class AcademicCalendarModel with _$AcademicCalendarModel {
  const factory AcademicCalendarModel({
    required int id,
    required String judul,
    required String unit,
    @JsonKey(name: 'tanggal_mulai') required String tanggalMulai,
    @JsonKey(name: 'tanggal_selesai') required String tanggalSelesai,
    required String keterangan,
  }) = _AcademicCalendarModel;

  factory AcademicCalendarModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicCalendarModelFromJson(json);
}

extension AcademicCalendarModelMapper on AcademicCalendarModel {
  AcademicCalendarEntity toEntity() => AcademicCalendarEntity(
    id: id,
    judul: judul,
    unit: unit,
    tanggalMulai: tanggalMulai,
    tanggalSelesai: tanggalSelesai,
    keterangan: keterangan,
  );
}
