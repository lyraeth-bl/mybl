import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/attendance_summary/attendance_summary.dart';

class Chart extends StatelessWidget {
  const Chart({super.key, required this.summary});

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final sections = _buildSections(colorScheme);

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 4,
            centerSpaceRadius: 72,
            sections: sections.isNotEmpty
                ? sections
                : [
                    // Empty state: single muted ring
                    PieChartSectionData(
                      color: colorScheme.surfaceContainerHighest,
                      value: 1,
                      title: '',
                      radius: 28,
                    ),
                  ],
          ),
        ),
        _CenterLabel(summary: summary, l10n: l10n),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(ColorScheme colorScheme) {
    final data = [
      (value: summary.present, color: Colors.green),
      (value: summary.late, color: colorScheme.primary),
      (value: summary.excused, color: Colors.amber),
      (value: summary.absent, color: colorScheme.error),
    ];

    return [
      for (final d in data)
        if (d.value > 0)
          PieChartSectionData(
            color: d.color,
            value: d.value.toDouble(),
            title: '',
            radius: 28,
          ),
    ];
  }
}

class _CenterLabel extends StatelessWidget {
  const _CenterLabel({required this.summary, required this.l10n});

  final AttendanceSummary summary;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final hasData = summary.total > 0;
    final percent = hasData
        ? '${(summary.attendanceRate * 100).toStringAsFixed(0)}%'
        : '-';
    final totalLabel = hasData ? '${summary.total} ${l10n.days}' : l10n.noData;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          percent,
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          totalLabel,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
