import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/academic_result/academic_result.dart';

part 'academic_result_model.freezed.dart';
part 'academic_result_model.g.dart';

@freezed
abstract class AcademicResultModel with _$AcademicResultModel {
  const factory AcademicResultModel({
    required int id,
    @JsonKey(name: "NIS") required String nis,
    @JsonKey(name: "Kelas") required String kelas,
    @JsonKey(name: "NomorKelas") required String nomorKelas,
    @JsonKey(name: "Nilai") required int nilai,
    @JsonKey(name: "Deskripsi") required int nilaiKe,
    @JsonKey(name: "Tanggal") required DateTime tanggal,
    @JsonKey(name: "AspekNilai") required String aspekNilai,
    @JsonKey(name: "Remedial") required String remedial,
    @JsonKey(name: "Tajaran") required String tajaran,
    @JsonKey(name: "Semester") required String semester,
    @JsonKey(name: "Keterangan") required String keterangan,
    @JsonKey(name: "jenis_nilai") required String jenisNilai,
    required String unit,
  }) = _AcademicResultModel;

  factory AcademicResultModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicResultModelFromJson(json);
}

@freezed
abstract class AcademicResultCategoriesModel
    with _$AcademicResultCategoriesModel {
  const factory AcademicResultCategoriesModel({
    @JsonKey(name: "nama_pelajaran") required String subjectName,
    @JsonKey(name: "nama_guru") String? subjectTeacherName,
    @JsonKey(name: "summary") required AcademicResultSummaryModel summary,
    @JsonKey(name: "items") required List<AcademicResultModel> listResult,
  }) = _AcademicResultCategoriesModel;

  factory AcademicResultCategoriesModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicResultCategoriesModelFromJson(json);
}

@freezed
abstract class AcademicResultDataModel with _$AcademicResultDataModel {
  const factory AcademicResultDataModel({
    @JsonKey(name: "overall_summary")
    required AcademicResultOverallSummaryModel overallSummaryResult,
    @JsonKey(name: "categories")
    required List<AcademicResultCategoriesModel> categories,
  }) = _AcademicResultDataModel;

  factory AcademicResultDataModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicResultDataModelFromJson(json);
}

@freezed
abstract class AcademicResultMetaModel with _$AcademicResultMetaModel {
  const factory AcademicResultMetaModel({
    @JsonKey(name: 'semester') required int semester,
    @JsonKey(name: 'tahun_ajaran') required String schoolSession,
  }) = _AcademicResultMetaModel;

  factory AcademicResultMetaModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicResultMetaModelFromJson(json);
}

@freezed
abstract class AcademicResultOverallSummaryModel
    with _$AcademicResultOverallSummaryModel {
  const factory AcademicResultOverallSummaryModel({
    required double average,
    @JsonKey(name: "nilai_akhir_sumatif") required double sumatifAverage,
    @JsonKey(name: "nilai_rapor") required double raportAverage,
    @JsonKey(name: "nilai_rapor_semester")
    required double raportSemesterAverage,
    @JsonKey(name: "total_penilaian") required int totalData,
  }) = _AcademicResultOverallSummaryModel;

  factory AcademicResultOverallSummaryModel.fromJson(
    Map<String, dynamic> json,
  ) => _$AcademicResultOverallSummaryModelFromJson(json);
}

@freezed
abstract class AcademicResultSummaryModel with _$AcademicResultSummaryModel {
  const factory AcademicResultSummaryModel({
    required double average,
    @JsonKey(name: 'total_penilaian') required int totalData,
  }) = _AcademicResultSummaryModel;

  factory AcademicResultSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicResultSummaryModelFromJson(json);
}

@freezed
abstract class AcademicResultResponseModel with _$AcademicResultResponseModel {
  const factory AcademicResultResponseModel({
    required bool error,
    required String message,
    @JsonKey(name: "meta") required AcademicResultMetaModel meta,
    @JsonKey(name: "data") required AcademicResultDataModel data,
  }) = _AcademicResultResponseModel;

  factory AcademicResultResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicResultResponseModelFromJson(json);
}

extension AcademicResultModelMapper on AcademicResultModel {
  AcademicResultEntity toEntity() => AcademicResultEntity(
    id: id,
    nis: nis,
    kelas: kelas,
    nomorKelas: nomorKelas,
    nilai: nilai,
    nilaiKe: nilaiKe,
    tanggal: tanggal,
    aspekNilai: aspekNilai,
    remedial: remedial,
    tajaran: tajaran,
    semester: semester,
    keterangan: keterangan,
    jenisNilai: jenisNilai,
    unit: unit,
  );
}

extension AcademicResultCategoriesModelMapper on AcademicResultCategoriesModel {
  AcademicResultCategories toEntity() => AcademicResultCategories(
    subjectName: subjectName,
    summary: summary.toEntity(),
    subjectTeacherName: subjectTeacherName,
    listResult: listResult.map((m) => m.toEntity()).toList(),
  );
}

extension AcademicResultDataModelMapper on AcademicResultDataModel {
  AcademicResultData toEntity() => AcademicResultData(
    overallSummaryResult: overallSummaryResult.toEntity(),
    categories: categories.map((m) => m.toEntity()).toList(),
  );
}

extension AcademicResultMetaModelMapper on AcademicResultMetaModel {
  AcademicResultMeta toEntity() =>
      AcademicResultMeta(semester: semester, schoolSession: schoolSession);
}

extension AcademicResultOverallSummaryModelMapper
    on AcademicResultOverallSummaryModel {
  AcademicResultOverallSummary toEntity() => AcademicResultOverallSummary(
    average: average,
    sumatifAverage: sumatifAverage,
    raportAverage: raportAverage,
    raportSemesterAverage: raportSemesterAverage,
    totalData: totalData,
  );
}

extension AcademicResultSummaryModelMapper on AcademicResultSummaryModel {
  AcademicResultSummary toEntity() =>
      AcademicResultSummary(average: average, totalData: totalData);
}

extension AcademicResultResponseModelMapper on AcademicResultResponseModel {
  AcademicResultResponse toEntity() => AcademicResultResponse(
    error: error,
    message: message,
    meta: meta.toEntity(),
    data: data.toEntity(),
  );
}
