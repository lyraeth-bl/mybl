// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../domain/entities/academic_result/academic_result.dart';

class AcademicResultSubjectView {
  const AcademicResultSubjectView({
    required this.category,
    required this.results,
    required this.average,
    required this.totalData,
  });

  final AcademicResultCategories category;
  final List<AcademicResultEntity> results;
  final double average;
  final int totalData;

  String get subjectName => category.subjectName;

  String? get teacherName => category.subjectTeacherName;

  String get latestDescription {
    final sortedResults = [...results]
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

    for (final result in sortedResults) {
      final description = result.keterangan.trim();
      if (description.isNotEmpty) return description;
    }

    return '-';
  }
}

List<AcademicResultSubjectView> academicResultSubjectsForSemester(
  List<AcademicResultCategories> categories,
  int semester,
) {
  return categories
      .map((category) {
        final results = category.listResult
            .where((result) => academicResultSemesterOf(result) == semester)
            .toList();
        final average = results.isEmpty
            ? 0.0
            : results.fold<double>(0, (total, result) => total + result.nilai) /
                  results.length;

        return AcademicResultSubjectView(
          category: category,
          results: results,
          average: average,
          totalData: results.length,
        );
      })
      .where((subject) => subject.totalData > 0)
      .toList();
}

int academicResultSemesterOf(AcademicResultEntity result) {
  final normalized = result.semester.toLowerCase();
  if (normalized.contains('2') || normalized.contains('genap')) return 2;
  return 1;
}

String academicResultFormatScore(double value) {
  final normalized = value.clamp(0, 100);
  final fixed = normalized.toStringAsFixed(2);

  return fixed.endsWith('00')
      ? normalized.toStringAsFixed(0)
      : fixed.replaceFirst(RegExp(r'0$'), '');
}

String academicResultGrade(double value) {
  if (value >= 90) return 'A';
  if (value >= 85) return 'B+';
  if (value >= 80) return 'B';
  if (value >= 75) return 'C+';
  if (value >= 70) return 'C';
  if (value >= 60) return 'D';
  return 'E';
}

Color academicResultScoreColor(BuildContext context, double value) {
  final colorScheme = Theme.of(context).colorScheme;
  if (value >= 90) return colorScheme.primary;
  if (value >= 80) return colorScheme.tertiary;
  if (value >= 70) return colorScheme.secondary;
  return colorScheme.error;
}
