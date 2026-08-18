// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/extracurricular_attendance/extracurricular_attendance.dart';
import 'extracurricular_attendance_status.dart';

/// A per-status recap of the sessions currently in view.
class ExtracurricularAttendanceSummarySection extends StatelessWidget {
  const ExtracurricularAttendanceSummarySection({
    super.key,
    required this.attendances,
  });

  final List<ExtracurricularAttendance> attendances;

  static const List<ExtracurricularAttendanceStatus> _summarizedStatuses = [
    ExtracurricularAttendanceStatus.present,
    ExtracurricularAttendanceStatus.excused,
    ExtracurricularAttendanceStatus.sick,
    ExtracurricularAttendanceStatus.unexcused,
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final counts = _countByStatus(attendances);

    return AppSliverGroup(
      title: l10n.attendanceSummary,
      titleStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      action: AppChipContainer.outlined(
        value: '${l10n.totalSession}: ${attendances.length}',
      ),
      child: AppFramedContainer(
        margin: .zero,
        elevation: 0,
        child: Row(
          crossAxisAlignment: .start,
          children: [
            for (final status in _summarizedStatuses)
              Expanded(
                child: _SummaryTile(status: status, count: counts[status] ?? 0),
              ),
          ],
        ),
      ),
    );
  }

  static Map<ExtracurricularAttendanceStatus, int> _countByStatus(
    List<ExtracurricularAttendance> attendances,
  ) {
    final counts = <ExtracurricularAttendanceStatus, int>{};

    for (final attendance in attendances) {
      final status = extracurricularAttendanceStatusFromRaw(attendance.status);
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.status, required this.count});

  final ExtracurricularAttendanceStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final (_, Color foregroundColor) = extracurricularAttendanceStatusColors(
      context,
      status,
    );

    return Column(
      children: [
        Text(
          '$count',
          style: textTheme.headlineSmall?.copyWith(
            color: foregroundColor,
            fontWeight: .bold,
          ),
        ),
        8.h,
        Text(
          extracurricularAttendanceStatusLabel(l10n, status, ''),
          textAlign: .center,
          maxLines: 2,
          overflow: .ellipsis,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
