// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'academic_result.freezed.dart';

@freezed
abstract class AcademicResultEntity with _$AcademicResultEntity {
  const factory AcademicResultEntity({
    required int id,
    required String nis,
    required String kelas,
    required String nomorKelas,
    required int nilai,
    required int nilaiKe,
    required DateTime tanggal,
    required String aspekNilai,
    required String remedial,
    required String tajaran,
    required String semester,
    required String keterangan,
    required String jenisNilai,
    required String unit,
  }) = _AcademicResultEntity;
}

@freezed
abstract class AcademicResultCategories with _$AcademicResultCategories {
  const factory AcademicResultCategories({
    required String subjectName,
    String? subjectTeacherName,
    required AcademicResultSummary summary,
    required List<AcademicResultEntity> listResult,
  }) = _AcademicResultCategories;
}

@freezed
abstract class AcademicResultData with _$AcademicResultData {
  const factory AcademicResultData({
    required AcademicResultOverallSummary overallSummaryResult,
    required List<AcademicResultCategories> categories,
  }) = _AcademicResultData;
}

@freezed
abstract class AcademicResultMeta with _$AcademicResultMeta {
  const factory AcademicResultMeta({
    required int semester,
    required String schoolSession,
  }) = _AcademicResultMeta;
}

@freezed
abstract class AcademicResultOverallSummary
    with _$AcademicResultOverallSummary {
  const factory AcademicResultOverallSummary({
    required double average,
    required double sumatifAverage,
    required double raportAverage,
    required double raportSemesterAverage,
    required int totalData,
  }) = _AcademicResultOverallSummary;
}

@freezed
abstract class AcademicResultSummary with _$AcademicResultSummary {
  const factory AcademicResultSummary({
    required double average,
    required int totalData,
  }) = _AcademicResultSummary;
}

@freezed
abstract class AcademicResultResponse with _$AcademicResultResponse {
  const factory AcademicResultResponse({
    required bool error,
    required String message,
    required AcademicResultMeta meta,
    required AcademicResultData data,
  }) = _AcademicResultResponse;
}
