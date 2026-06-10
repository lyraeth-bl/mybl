import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/time_table/time_table.dart';

part 'time_table_model.freezed.dart';
part 'time_table_model.g.dart';

@freezed
abstract class TimeTableModel with _$TimeTableModel {
  const factory TimeTableModel({
    required String id,
    @JsonKey(name: "nm_kelas") required String kelas,
    @JsonKey(name: "jam_ke") required String jamKe,
    @JsonKey(name: "awal") required String jamMulai,
    @JsonKey(name: "akhir") required String jamSelesai,
    required String hari,
    @JsonKey(name: "nama_guru") required String namaGuru,
    @JsonKey(name: "nama_mapel") required String namaMataPelajaran,
    @JsonKey(name: "kode_mapel") required String kodeMataPelajaran,
  }) = _TimeTableModel;

  factory TimeTableModel.fromJson(Map<String, dynamic> json) =>
      _$TimeTableModelFromJson(json);
}

extension TimeTableModelMapper on TimeTableModel {
  TimeTable toEntity() => TimeTable(
    id: id,
    kelas: kelas,
    jamKe: jamKe,
    jamMulai: jamMulai,
    jamSelesai: jamSelesai,
    hari: hari,
    namaGuru: namaGuru,
    namaMataPelajaran: namaMataPelajaran,
    kodeMataPelajaran: kodeMataPelajaran,
  );
}
