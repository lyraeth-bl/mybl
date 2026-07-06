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

  const AcademicResultEntity._();

  int get semesterNumber {
    final normalized = semester.toLowerCase();
    if (normalized.contains('2') || normalized.contains('genap')) return 2;
    return 1;
  }
}

@freezed
abstract class AcademicResultCategories with _$AcademicResultCategories {
  const factory AcademicResultCategories({
    required String subjectName,
    String? subjectTeacherName,
    required AcademicResultSummary summary,
    required List<AcademicResultEntity> listResult,
  }) = _AcademicResultCategories;

  const AcademicResultCategories._();

  List<AcademicResultEntity> resultsForSemester(int semester) =>
      listResult.where((result) => result.semesterNumber == semester).toList();

  int totalDataForSemester(int semester) =>
      resultsForSemester(semester).length;

  double averageForSemester(int semester) {
    final results = resultsForSemester(semester);
    if (results.isEmpty) return 0.0;

    return results.fold<double>(0, (total, result) => total + result.nilai) /
        results.length;
  }
}

@freezed
abstract class AcademicResultData with _$AcademicResultData {
  const factory AcademicResultData({
    required AcademicResultOverallSummary overallSummaryResult,
    required List<AcademicResultCategories> categories,
  }) = _AcademicResultData;

  const AcademicResultData._();

  int totalDataForSemester(int semester) => categories.fold(
    0,
    (total, category) => total + category.totalDataForSemester(semester),
  );

  double averageForSemester(int semester) {
    final total = totalDataForSemester(semester);
    if (total == 0) return 0.0;

    final weightedSum = categories.fold<double>(
      0,
      (sum, category) =>
          sum +
          category.averageForSemester(semester) *
              category.totalDataForSemester(semester),
    );

    return weightedSum / total;
  }
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

String academicResultGradeLabel(double average) {
  if (average >= 90) return 'A';
  if (average >= 85) return 'B+';
  if (average >= 80) return 'B';
  if (average >= 75) return 'C+';
  if (average >= 70) return 'C';
  if (average >= 60) return 'D';
  return 'E';
}
