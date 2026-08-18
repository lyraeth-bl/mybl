// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/extracurricular_attendance/extracurricular_attendance.dart';
import 'extracurricular_attendance_status.dart';

class ExtracurricularAttendanceListSection extends StatelessWidget {
  const ExtracurricularAttendanceListSection({
    super.key,
    required this.attendances,
    required this.emptyMessage,
  });

  final List<ExtracurricularAttendance> attendances;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: l10n.extracurricularAttendance,
      titleStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      action: AppChipContainer.outlined(
        value: l10n.dataCount(attendances.length),
      ),
      sliver: attendances.isEmpty
          ? SliverToBoxAdapter(
              child: AppEmptyState(
                icon: Icons.event_busy_outlined,
                message: emptyMessage,
              ),
            )
          : SliverList.list(
              children: _groupedChildren(context).makeListAnimate(),
            ),
    );
  }

  /// The cards for [attendances], newest first, preceded by a month header
  /// each time the month changes.
  List<Widget> _groupedChildren(BuildContext context) {
    final sorted = [...attendances]
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
    final children = <Widget>[];
    DateTime? currentMonth;

    for (final attendance in sorted) {
      final month = DateTime(attendance.tanggal.year, attendance.tanggal.month);

      if (currentMonth != month) {
        currentMonth = month;
        children.add(_MonthHeader(month: month));
      }

      children.add(_ExtracurricularAttendanceCard(attendance: attendance));
    }

    return children;
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const .only(top: 8, bottom: 12),
      child: Text(
        month.toMonthYearFormat(context),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ExtracurricularAttendanceCard extends StatelessWidget {
  const _ExtracurricularAttendanceCard({required this.attendance});

  final ExtracurricularAttendance attendance;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final status = extracurricularAttendanceStatusFromRaw(attendance.status);
    final (Color backgroundColor, Color foregroundColor) =
        extracurricularAttendanceStatusColors(context, status);
    final title = attendance.materi.trim().isEmpty
        ? attendance.namaKegiatan
        : attendance.materi;

    return AppFramedContainer(
      margin: const .only(bottom: 12),
      elevation: 0,
      gap: .zero,
      onTap: () =>
          context.push('/extracurricular/attendance/${attendance.sessionId}'),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          AppIconContainer(
            icon: extracurricularAttendanceStatusIcon(status),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: .ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                4.h,
                Text(
                  attendance.namaKegiatan,
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                8.h,
                Text(
                  attendance.tanggal.toDayMonthYearFormat(context),
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppChipContainer(
            value: extracurricularAttendanceStatusLabel(
              l10n,
              status,
              attendance.status,
            ),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
        ].separatedBy(12.w),
      ),
    );
  }
}
