import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class Chart extends StatelessWidget {
  const Chart({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return PieChart(
      PieChartData(
        sectionsSpace: 6,
        centerSpaceRadius: 60,
        sections: [
          PieChartSectionData(
            color: colorScheme.primaryContainer,
            value: 4.toDouble(),
          ),
          PieChartSectionData(
            color: colorScheme.errorContainer,
            value: 5.toDouble(),
          ),
        ],
      ),
    );
  }
}
