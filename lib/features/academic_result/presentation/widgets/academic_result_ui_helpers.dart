// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/academic_result/academic_result.dart';

class AcademicResultSubjectView {
  const AcademicResultSubjectView({
    required this.category,
    required this.results,
    required this.average,
    required this.totalData,
  });

  factory AcademicResultSubjectView.placeholder(int index) {
    return AcademicResultSubjectView(
      category: AcademicResultCategories(
        subjectName: 'Subject',
        subjectTeacherName: 'Teacher',
        summary: const AcademicResultSummary(average: 0, totalData: 0),
        listResult: const [],
      ),
      results: const [],
      average: 0,
      totalData: 0,
    );
  }

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
      .map(
        (category) => AcademicResultSubjectView(
          category: category,
          results: category.resultsForSemester(semester),
          average: category.averageForSemester(semester),
          totalData: category.totalDataForSemester(semester),
        ),
      )
      .where((subject) => subject.totalData > 0)
      .toList();
}

String academicResultFormatScore(double value) {
  final normalized = value.clamp(0, 100);
  final fixed = normalized.toStringAsFixed(2);

  return fixed.endsWith('00')
      ? normalized.toStringAsFixed(0)
      : fixed.replaceFirst(RegExp(r'0$'), '');
}

Color academicResultScoreColor(BuildContext context, double value) {
  final appColors = AppColors.of(context);
  if (value >= 80) return appColors.success;
  if (value >= 70) return appColors.warning;
  return Theme.of(context).colorScheme.error;
}
