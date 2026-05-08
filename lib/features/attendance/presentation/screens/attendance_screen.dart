import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/widgets/custom_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';
import '../widgets/calendar.dart';
import '../widgets/chart.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MonthlyAttendanceBloc>(
      create: (context) => di<MonthlyAttendanceBloc>(),
      child: const _AttendanceScreenView(),
    );
  }
}

class _AttendanceScreenView extends StatefulWidget {
  const _AttendanceScreenView();

  @override
  State<_AttendanceScreenView> createState() => _AttendanceScreenViewState();
}

class _AttendanceScreenViewState extends State<_AttendanceScreenView> {
  final DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MonthlyAttendanceBloc>().add(
        MonthlyAttendanceEvent.monthChangeRequested(
          month: now.month,
          year: now.year,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const _AttendanceScreenHeader(),
          const _AttendanceNavigationButton(),
          const _AttendanceSummaryContainer(),
          const _AttendanceMonthlyProgress(),
          const _AttendanceCalendarContainer(),
          const _AttendanceLegends(),
          const _AttendanceChart(),
        ],
      ),
    );
  }
}

class _AttendanceScreenHeader extends StatelessWidget {
  const _AttendanceScreenHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SliverAppBar.medium(
      title: Text(l10n.dailyAttendance),
      centerTitle: true,
      floating: false,
      pinned: true,
    );
  }
}

class _AttendanceNavigationButton extends StatelessWidget {
  const _AttendanceNavigationButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: CustomContainer(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.chevron_left),
                tooltip: l10n.previousMonth,
              ),

              Text(
                "Mei 2026",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right),
                tooltip: l10n.nextMonth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceSummaryContainer extends StatelessWidget {
  const _AttendanceSummaryContainer();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final summaryData = [
      (label: l10n.present, value: '19'),
      (label: l10n.late, value: '5'),
      (label: l10n.excused, value: '2'),
      (label: l10n.absent, value: '0'),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
        child: Row(
          children: [
            for (int i = 0; i < summaryData.length; i++) ...[
              Expanded(
                child: _SummaryCard(
                  label: summaryData[i].label,
                  value: summaryData[i].value,
                ),
              ),
              if (i != summaryData.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomContainer(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceMonthlyProgress extends StatelessWidget {
  const _AttendanceMonthlyProgress();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.thisMonthlyAttendance,
                  style: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),

                Text(
                  "15%",
                  style: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCalendarContainer extends StatelessWidget {
  const _AttendanceCalendarContainer();

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    return SliverToBoxAdapter(
      child: CustomContainer(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        child: Calendar(focusedDay: now),
      ),
    );
  }
}

class _AttendanceLegends extends StatelessWidget {
  const _AttendanceLegends();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _LegendsRow(dotColor: Colors.green, label: l10n.present),
            _LegendsRow(dotColor: colorScheme.primary, label: l10n.late),
            _LegendsRow(dotColor: Colors.amber, label: l10n.excused),
            _LegendsRow(dotColor: colorScheme.error, label: l10n.absent),
          ],
        ),
      ),
    );
  }
}

class _LegendsRow extends StatelessWidget {
  const _LegendsRow({required this.dotColor, required this.label});

  final Color dotColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.labelSmall!.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AttendanceChart extends StatelessWidget {
  const _AttendanceChart();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: CustomContainer(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

        child: const SizedBox(height: 250, child: Chart()),
      ),
    );
  }
}
