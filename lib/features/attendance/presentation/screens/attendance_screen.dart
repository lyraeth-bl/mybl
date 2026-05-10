import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/custom_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/attendance_status/attendance_status.dart';
import '../../domain/entities/attendance_summary/attendance_summary.dart';
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
  late final List<Widget> _animatedChildren;

  @override
  void initState() {
    super.initState();
    _animatedChildren = [
      const _AttendanceNavigationButton(),
      const _AttendanceSummaryContainer(),
      const _AttendanceMonthlyProgress(),
      const _AttendanceCalendarContainer(),
      const _AttendanceLegends(),
      const _AttendanceChart(),
    ].makeListAnimate();

    final now = DateTime.now();
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const _AttendanceScreenHeader(),
          SliverList.list(children: _animatedChildren),
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
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar.medium(
      title: Text(
        l10n.dailyAttendance,
        style: const TextStyle(fontWeight: FontWeight(700)),
      ),
      backgroundColor: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      centerTitle: true,
      floating: false,
      pinned: true,
    );
  }
}

class _AttendanceNavigationButton extends StatelessWidget {
  const _AttendanceNavigationButton();

  String _monthLabel(int month, int year, String locale) =>
      DateFormat('MMMM yyyy', locale).format(DateTime(year, month));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();

    return BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
      buildWhen: (prev, curr) {
        final isSupported = curr.maybeWhen(
          loading: (_, _) => true,
          success: (_, _, _, _, _) => true,
          initial: () => true,
          orElse: () => false,
        );
        if (!isSupported) return false;

        final prevData = (
          month: prev.maybeWhen(
            success: (m, _, _, _, _) => m,
            loading: (m, _) => m,
            orElse: () => 0,
          ),
          year: prev.maybeWhen(
            success: (_, y, _, _, _) => y,
            loading: (_, y) => y,
            orElse: () => 0,
          ),
          isLoading: prev.maybeWhen(
            loading: (_, _) => true,
            orElse: () => false,
          ),
        );
        final currData = (
          month: curr.maybeWhen(
            success: (m, _, _, _, _) => m,
            loading: (m, _) => m,
            orElse: () => 0,
          ),
          year: curr.maybeWhen(
            success: (_, y, _, _, _) => y,
            loading: (_, y) => y,
            orElse: () => 0,
          ),
          isLoading: curr.maybeWhen(
            loading: (_, _) => true,
            orElse: () => false,
          ),
        );
        return prevData != currData;
      },
      builder: (context, state) {
        final (month, year) = state.maybeWhen(
          success: (month, year, _, _, _) => (month, year),
          loading: (month, year) => (month, year),
          orElse: () => (DateTime.now().month, DateTime.now().year),
        );
        final isLoading = state.maybeWhen(
          loading: (_, _) => true,
          orElse: () => false,
        );

        return CustomContainer(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  onPressed: isLoading
                      ? null
                      : () => context.read<MonthlyAttendanceBloc>().add(
                          const MonthlyAttendanceEvent.previousMonthRequested(),
                        ),
                  icon: const Icon(Icons.chevron_left),
                  tooltip: l10n.previousMonth,
                ),
                Text(
                  _monthLabel(month, year, locale),
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: isLoading
                      ? null
                      : () => context.read<MonthlyAttendanceBloc>().add(
                          const MonthlyAttendanceEvent.nextMonthRequested(),
                        ),
                  icon: const Icon(Icons.chevron_right),
                  tooltip: l10n.nextMonth,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AttendanceSummaryContainer extends StatelessWidget {
  const _AttendanceSummaryContainer();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
      buildWhen: (prev, curr) {
        final prevData = (
          isLoading: prev.maybeWhen(
            loading: (_, _) => true,
            orElse: () => false,
          ),
          summary: prev.maybeWhen(
            success: (_, _, _, _, s) => s,
            orElse: () => const AttendanceSummary(),
          ),
        );
        final currData = (
          isLoading: curr.maybeWhen(
            loading: (_, _) => true,
            orElse: () => false,
          ),
          summary: curr.maybeWhen(
            success: (_, _, _, _, s) => s,
            orElse: () => const AttendanceSummary(),
          ),
        );
        return prevData != currData;
      },
      builder: (context, state) {
        final summary = state.maybeWhen(
          success: (_, _, _, _, summary) => summary,
          orElse: () => const AttendanceSummary(),
        );
        final isLoading = state.maybeWhen(
          loading: (_, _) => true,
          orElse: () => false,
        );

        final cards = [
          (label: l10n.present, value: summary.present),
          (label: l10n.late, value: summary.late),
          (label: l10n.excused, value: summary.excused),
          (label: l10n.absent, value: summary.absent),
        ];

        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                Expanded(
                  child: _SummaryCard(
                    label: cards[i].label,
                    value: cards[i].value.toString(),
                    isLoading: isLoading,
                  ),
                ),
                if (i != cards.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.isLoading,
  });

  final String label;
  final String value;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomContainer(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child:
                Text(
                  value,

                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ).toShimmer(
                  context,
                  alignment: Alignment.center,
                  width: 24,
                  height: 28,
                  isLoading: isLoading,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: textTheme.labelSmall?.copyWith(
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

    return BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
      buildWhen: (prev, curr) {
        final prevRate = prev.maybeWhen(
          success: (_, _, _, _, s) => s.attendanceRate,
          orElse: () => 0.0,
        );
        final currRate = curr.maybeWhen(
          success: (_, _, _, _, s) => s.attendanceRate,
          orElse: () => 0.0,
        );
        return prevRate != currRate;
      },
      builder: (context, state) {
        final summary = state.maybeWhen(
          success: (_, _, _, _, summary) => summary,
          orElse: () => const AttendanceSummary(),
        );

        final rate = summary.attendanceRate;
        final percent = '${(rate * 100).toStringAsFixed(0)}%';

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.thisMonthlyAttendance,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    percent,

                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: rate),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (_, value, _) => LinearProgressIndicator(value: value),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AttendanceCalendarContainer extends StatelessWidget {
  const _AttendanceCalendarContainer();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
      buildWhen: (prev, curr) {
        final prevData = (
          month: prev.maybeWhen(
            success: (m, _, _, _, _) => m,
            loading: (m, _) => m,
            orElse: () => 0,
          ),
          year: prev.maybeWhen(
            success: (_, y, _, _, _) => y,
            loading: (_, y) => y,
            orElse: () => 0,
          ),
          map: prev.maybeWhen(
            success: (_, _, _, am, _) => am,
            orElse: () => null,
          ),
        );
        final currData = (
          month: curr.maybeWhen(
            success: (m, _, _, _, _) => m,
            loading: (m, _) => m,
            orElse: () => 0,
          ),
          year: curr.maybeWhen(
            success: (_, y, _, _, _) => y,
            loading: (_, y) => y,
            orElse: () => 0,
          ),
          map: curr.maybeWhen(
            success: (_, _, _, am, _) => am,
            orElse: () => null,
          ),
        );
        return prevData != currData;
      },
      builder: (context, state) {
        final focusedDay = state.maybeWhen(
          success: (month, year, _, _, _) => DateTime(year, month),
          loading: (month, year) => DateTime(year, month),
          orElse: () => DateTime.now(),
        );
        final attendanceMap = state.maybeWhen(
          success: (_, _, _, attendanceMap, _) => attendanceMap,
          orElse: () => const <DateTime, AttendanceStatus>{},
        );

        return RepaintBoundary(
          child: CustomContainer(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            child: Calendar(
              focusedDay: focusedDay,
              attendanceData: attendanceMap,
            ),
          ),
        );
      },
    );
  }
}

class _AttendanceLegends extends StatelessWidget {
  const _AttendanceLegends();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        alignment: WrapAlignment.spaceEvenly,
        children: [
          _LegendItem(dotColor: Colors.green, label: l10n.present),
          _LegendItem(dotColor: colorScheme.primary, label: l10n.late),
          _LegendItem(dotColor: Colors.amber, label: l10n.excused),
          _LegendItem(dotColor: colorScheme.error, label: l10n.absent),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.dotColor, required this.label});

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
        const SizedBox(width: 6),
        Text(
          label,

          style: textTheme.labelSmall?.copyWith(
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
    return BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
      buildWhen: (prev, curr) {
        final prevSummary = prev.maybeWhen(
          success: (_, _, _, _, s) => s,
          orElse: () => const AttendanceSummary(),
        );
        final currSummary = curr.maybeWhen(
          success: (_, _, _, _, s) => s,
          orElse: () => const AttendanceSummary(),
        );
        return prevSummary != currSummary;
      },
      builder: (context, state) {
        final summary = state.maybeWhen(
          success: (_, _, _, _, s) => s,
          orElse: () => const AttendanceSummary(),
        );

        return RepaintBoundary(
          child: CustomContainer(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SizedBox(height: 250, child: Chart(summary: summary)),
          ),
        );
      },
    );
  }
}
