// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/academic_result/academic_result.dart';
import 'academic_result_score_summary_section.dart';
import 'academic_result_semester_filter_section.dart';
import 'academic_result_subject_list_section.dart';
import 'academic_result_ui_helpers.dart';

class AcademicResultContent extends StatefulWidget {
  const AcademicResultContent({
    super.key,
    required this.academicResult,
    this.isLoading = false,
  });

  const AcademicResultContent.loading({super.key})
    : academicResult = null,
      isLoading = true;

  final AcademicResultResponse? academicResult;
  final bool isLoading;

  @override
  State<AcademicResultContent> createState() => _AcademicResultContentState();
}

class _AcademicResultContentState extends State<AcademicResultContent> {
  late int _selectedSemester;

  @override
  void initState() {
    super.initState();
    _selectedSemester = widget.academicResult?.meta.semester == 2 ? 2 : 1;
  }

  @override
  void didUpdateWidget(AcademicResultContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextSemester = widget.academicResult?.meta.semester == 2 ? 2 : 1;
    if (oldWidget.academicResult?.meta.semester !=
        widget.academicResult?.meta.semester) {
      _selectedSemester = nextSemester;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subjects = widget.isLoading
        ? List<AcademicResultSubjectView>.generate(
            3,
            AcademicResultSubjectView.placeholder,
          )
        : academicResultSubjectsForSemester(
            widget.academicResult?.data.categories ?? const [],
            _selectedSemester,
          );
    final totalData = subjects.fold(
      0,
      (total, subject) => total + subject.totalData,
    );
    final average = totalData == 0
        ? 0.0
        : subjects.fold<double>(
                0,
                (total, subject) =>
                    total + (subject.average * subject.totalData),
              ) /
              totalData;

    return SliverMainAxisGroup(
      slivers: [
        AcademicResultScoreSummarySection(
          average: average,
          totalData: totalData,
          isLoading: widget.isLoading,
        ),
        AcademicResultSemesterFilterSection(
          selectedSemester: _selectedSemester,
          isLoading: widget.isLoading,
          onChanged: (semester) {
            setState(() => _selectedSemester = semester);
          },
        ),
        AcademicResultSubjectListSection(
          subjects: subjects,
          emptyMessage: l10n.noData,
          isLoading: widget.isLoading,
        ),
      ],
    );
  }
}
