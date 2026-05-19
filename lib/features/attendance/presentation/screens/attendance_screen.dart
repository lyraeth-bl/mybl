// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../core/widgets/titled_content_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/attendance_entity/attendance_entity.dart';
import '../../domain/entities/attendance_status/attendance_status.dart';
import '../../domain/entities/attendance_summary/attendance_summary.dart';
import '../bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';
import '../widgets/calendar.dart';
import '../widgets/chart.dart';

/// Layar utama buat mantau absen bulanan lo.
///
/// Di sini user bisa liat rangkuman absen (masuk, telat, bolos), liat kalender absen,
/// sampe liat grafik progres-nya. Screen ini juga dibungkus [BlocProvider] biar
/// [MonthlyAttendanceBloc] siap tempur di dalemnya.
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

/// "Dapur" utama dari [AttendanceScreen].
///
/// Widget ini yang ngatur inisialisasi data pas pertama kali dibuka (lewat `initState`)
/// dan nyusun layout pake [CustomScrollView] biar tampilannya kece dan smooth pas di-scroll.
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
    // Nyiapin list widget yang bakal muncul pake animasi biar nggak kaku.
    _animatedChildren = [
      const SizedBox(height: 24),
      const _AttendanceSummaryContainer(),
      const SizedBox(height: 16),
      const _AttendanceCalendarContainer(),
      const SizedBox(height: 16),
      const _AttendanceChart(),
    ].makeListAnimate();

    // Langsung request data absen bulan sekarang pas screen baru nongol.
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: _AttendanceRefreshWrapper(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const _AttendanceScreenHeader(),
            SliverList.list(children: _animatedChildren),
          ],
        ),
      ),
    );
  }
}

/// Bungkus andalan buat fitur pull-to-refresh di halaman absen.
///
/// Pas ditarik ke bawah, dia bakal minta [MonthlyAttendanceBloc] buat ambil data
/// terbaru (force refresh) sesuai bulan yang lagi aktif diliat sama user.
class _AttendanceRefreshWrapper extends StatelessWidget {
  const _AttendanceRefreshWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () {
        final state = context.read<MonthlyAttendanceBloc>().state;

        // Cari tau lagi liat bulan & tahun berapa, kalo nggak ada ya balik ke sekarang.
        final month = state.maybeWhen(
          success: (m, _, _, _, _, _) => m,
          loading: (m, _) => m,
          orElse: () => DateTime.now().month,
        );
        final year = state.maybeWhen(
          success: (_, y, _, _, _, _) => y,
          loading: (_, y) => y,
          orElse: () => DateTime.now().year,
        );

        return blocRefresh<
          MonthlyAttendanceBloc,
          MonthlyAttendanceEvent,
          MonthlyAttendanceState
        >(
          context: context,
          event: MonthlyAttendanceEvent.monthChangeRequested(
            month: month,
            year: year,
            forceRefresh: true,
          ),
          isDone: (state) => state.maybeWhen(
            success: (_, _, _, _, _, _) => true,
            failure: (_) => true,
            orElse: () => false,
          ),
        );
      },
      child: child,
    );
  }
}

/// Header kece buat screen absen.
///
/// Pake [SliverAppBar.medium] biar tampilannya kekinian dan bisa ngumpet pas di-scroll,
/// tapi tetep "pinned" biar user nggak lupa lagi buka menu apa.
class _AttendanceScreenHeader extends StatelessWidget {
  const _AttendanceScreenHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SliverAppBar.medium(
      title: Text(
        l10n.dailyAttendance,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      centerTitle: true,
      floating: false,
      pinned: true,
    );
  }
}

/// Container buat kartu-kartu rangkuman absen.
///
/// Isinya ada total Masuk, Telat, Izin, ama Alpa. Semuanya ditampilin pake
/// [ListView] horizontal biar enak diliat dan responsif.
class _AttendanceSummaryContainer extends StatelessWidget {
  const _AttendanceSummaryContainer();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
      buildWhen: (prev, curr) {
        final prevData = (
          isLoading: prev.maybeWhen(
            loading: (_, _) => true,
            orElse: () => false,
          ),
          summary: prev.maybeWhen(
            success: (_, _, _, _, _, s) => s,
            orElse: () => const AttendanceSummary(),
          ),
        );
        final currData = (
          isLoading: curr.maybeWhen(
            loading: (_, _) => true,
            orElse: () => false,
          ),
          summary: curr.maybeWhen(
            success: (_, _, _, _, _, s) => s,
            orElse: () => const AttendanceSummary(),
          ),
        );
        return prevData != currData;
      },
      builder: (context, state) {
        final summary = state.maybeWhen(
          success: (_, _, _, _, _, summary) => summary,
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
        final rate = summary.attendanceRate;
        final percent = '${(rate * 100).toStringAsFixed(0)}%';

        return TitledContentContainer(
          title: l10n.attendanceSummary,
          contentPadding: const EdgeInsets.all(16),
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
              const SizedBox(height: 16),
              SizedBox(
                height: 80,
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        final shape = index.makeHorizontalGoogleShape(
                          cards.length - 1,
                        );

                        return SizedBox(
                          width: constraints.maxWidth / cards.length,
                          child: _SummaryCard(
                            label: card.label,
                            value: card.value.toString(),
                            shapeBorder: shape,
                            isLoading: isLoading,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Si kartu kecil sakti buat nampilin angka rangkuman.
///
/// Kalo datanya masih ditarik (loading), dia otomatis bakal nunjukin animasi shimmer
/// biar user nggak bengong liatin layar kosong.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.isLoading,
    this.shapeBorder,
  });

  final String label;
  final String value;
  final bool isLoading;
  final ShapeBorder? shapeBorder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.filled(
      color: colorScheme.surfaceContainerLowest,
      margin: const EdgeInsets.all(2),
      shape: shapeBorder,
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

/// Jembatan buat nampilin kalender absen beserta keterangannya.
///
/// Widget ini ngebungkus [Calendar] biar sinkron sama data dari [MonthlyAttendanceBloc].
/// Dia ngatur kapan harus nampilin data titik-titik warna di kalender.
class _AttendanceCalendarContainer extends StatelessWidget {
  const _AttendanceCalendarContainer();

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
        final prevData = (
          month: prev.maybeWhen(
            success: (m, _, _, _, _, _) => m,
            loading: (m, _) => m,
            orElse: () => 0,
          ),
          year: prev.maybeWhen(
            success: (_, y, _, _, _, _) => y,
            loading: (_, y) => y,
            orElse: () => 0,
          ),
          map: prev.maybeWhen(
            success: (_, _, _, am, _, _) => am,
            orElse: () => null,
          ),
          isLoading: prev.maybeWhen(
            loading: (_, _) => true,
            orElse: () => false,
          ),
        );
        final currData = (
          month: curr.maybeWhen(
            success: (m, _, _, _, _, _) => m,
            loading: (m, _) => m,
            orElse: () => 0,
          ),
          year: curr.maybeWhen(
            success: (_, y, _, _, _, _) => y,
            loading: (_, y) => y,
            orElse: () => 0,
          ),
          map: curr.maybeWhen(
            success: (_, _, _, am, _, _) => am,
            orElse: () => null,
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
          success: (month, year, _, _, _, _) => (month, year),
          loading: (month, year) => (month, year),
          orElse: () => (DateTime.now().month, DateTime.now().year),
        );
        final focusedDay = state.maybeWhen(
          success: (month, year, _, _, _, _) => DateTime(year, month),
          loading: (month, year) => DateTime(year, month),
          orElse: () => DateTime.now(),
        );
        final attendanceMap = state.maybeWhen(
          success: (_, _, _, attendanceMap, _, _) => attendanceMap,
          orElse: () => const <DateTime, AttendanceStatus>{},
        );
        final entityMap = state.maybeWhen(
          success: (_, _, _, _, entityMap, _) => entityMap,
          orElse: () => const <DateTime, AttendanceEntity>{},
        );
        final isLoading = state.maybeWhen(
          loading: (_, _) => true,
          orElse: () => false,
        );

        return RepaintBoundary(
          child: TitledContentContainer(
            title: l10n.attendanceCalendar,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            contentPadding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
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
                const SizedBox(height: 12),
                Calendar(
                  focusedDay: focusedDay,
                  attendanceData: attendanceMap,
                  entityData: entityMap,
                ),
                const SizedBox(height: 16),
                const _AttendanceLegends(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tukang jelasin arti titik warna di kalender.
///
/// Biar user nggak bingung, ini list legenda-nya: Hijau buat Masuk, Primary buat Telat,
/// Kuning buat Izin, ama Merah buat Alpa.
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

/// Item kecil buat satu baris legenda (titik + teks).
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

/// Visualisasi data absen lewat chart yang interaktif.
///
/// Biar data rangkuman tadi nggak cuma teks, kita kasih [Chart] biar user
/// bisa liat perbandingannya secara visual.
class _AttendanceChart extends StatelessWidget {
  const _AttendanceChart();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
      buildWhen: (prev, curr) {
        final prevSummary = prev.maybeWhen(
          success: (_, _, _, _, _, s) => s,
          orElse: () => const AttendanceSummary(),
        );
        final currSummary = curr.maybeWhen(
          success: (_, _, _, _, _, s) => s,
          orElse: () => const AttendanceSummary(),
        );
        return prevSummary != currSummary;
      },
      builder: (context, state) {
        final summary = state.maybeWhen(
          success: (_, _, _, _, _, s) => s,
          orElse: () => const AttendanceSummary(),
        );

        return RepaintBoundary(
          child: TitledContentContainer(
            title: AppLocalizations.of(context)!.attendanceChart,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: SizedBox(height: 250, child: Chart(summary: summary)),
          ),
        );
      },
    );
  }
}
