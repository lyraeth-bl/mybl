// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/extracurricular_attendance/extracurricular_attendance.dart';
import 'extracurricular_attendance_filter_section.dart';
import 'extracurricular_attendance_list_section.dart';
import 'extracurricular_attendance_summary_section.dart';

class ExtracurricularAttendanceContent extends StatefulWidget {
  const ExtracurricularAttendanceContent({
    super.key,
    required this.attendances,
  });

  final List<ExtracurricularAttendance> attendances;

  @override
  State<ExtracurricularAttendanceContent> createState() =>
      _ExtracurricularAttendanceContentState();
}

class _ExtracurricularAttendanceContentState
    extends State<ExtracurricularAttendanceContent> {
  String? _selectedActivity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredAttendances = _filteredAttendances(widget.attendances);
    final hasMultipleActivities =
        widget.attendances.map((item) => item.namaKegiatan).toSet().length > 1;

    return SliverMainAxisGroup(
      slivers: [
        ExtracurricularAttendanceSummarySection(
          attendances: filteredAttendances,
        ),
        if (hasMultipleActivities)
          ExtracurricularAttendanceFilterSection(
            attendances: widget.attendances,
            selectedActivity: _selectedActivity,
            onChanged: (value) => setState(() => _selectedActivity = value),
          ),
        ExtracurricularAttendanceListSection(
          attendances: filteredAttendances,
          emptyMessage: l10n.noExtracurricularAttendanceData,
        ),
      ],
    );
  }

  List<ExtracurricularAttendance> _filteredAttendances(
    List<ExtracurricularAttendance> attendances,
  ) {
    final selectedActivity = _selectedActivity;
    if (selectedActivity == null) return attendances;

    return attendances
        .where((item) => item.namaKegiatan == selectedActivity)
        .toList();
  }
}
