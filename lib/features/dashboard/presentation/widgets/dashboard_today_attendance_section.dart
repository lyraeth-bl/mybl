// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/presentation/bloc/daily_attendance_bloc/daily_attendance_bloc.dart';

class DashboardTodayAttendanceSection extends StatelessWidget {
  const DashboardTodayAttendanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final successColor = AppColors.of(context).success;
    final _DashboardAttendanceIconStyle positiveIconStyle = (
      backgroundColor: successColor.withValues(alpha: 0.18),
      foregroundColor: successColor,
    );
    final _DashboardAttendanceIconStyle negativeIconStyle = (
      backgroundColor: colorScheme.error.withValues(alpha: 0.14),
      foregroundColor: colorScheme.error,
    );
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toString();

    return AppSliverGroup(
      title: l10n.dailyAttendance,
      titleStyle: textTheme.titleMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      action: AppChipContainer(value: DateFormat.yMMMMd(locale).format(now)),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.4,
        children: [
          BlocBuilder<DailyAttendanceBloc, DailyAttendanceState>(
            builder: (context, state) {
              final isLoading = state.maybeWhen(
                loading: () => true,
                orElse: () => false,
              );
              final dailyAttendance = state.whenOrNull(
                success: (dailyAttendance) => dailyAttendance,
              );

              return _DashboardTodayAttendanceContainer(
                title: l10n.checkIn,
                icon: Icons.call_received,
                descriptionValue: l10n.westernIndonesiaTime,
                value: _formatNullableTime(dailyAttendance?.jamCheckIn, locale),
                isLoading: isLoading,
                iconBackgroundColor: positiveIconStyle.backgroundColor,
                iconForegroundColor: positiveIconStyle.foregroundColor,
              );
            },
          ),
          BlocBuilder<DailyAttendanceBloc, DailyAttendanceState>(
            builder: (context, state) {
              final isLoading = state.maybeWhen(
                loading: () => true,
                orElse: () => false,
              );
              final dailyAttendance = state.whenOrNull(
                success: (dailyAttendance) => dailyAttendance,
              );

              return _DashboardTodayAttendanceContainer(
                title: l10n.checkOut,
                icon: Icons.call_made,
                descriptionValue: l10n.westernIndonesiaTime,
                value: _formatNullableTime(
                  dailyAttendance?.jamCheckOut,
                  locale,
                ),
                crossAxisAlignment: .end,
                isLoading: isLoading,
                iconBackgroundColor: negativeIconStyle.backgroundColor,
                iconForegroundColor: negativeIconStyle.foregroundColor,
              );
            },
          ),
          // BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
          //   builder: (context, state) {
          //     final isLoading = state.maybeWhen(
          //       loading: (_, _) => true,
          //       orElse: () => false,
          //     );
          //     final summary = state.maybeWhen(
          //       success: (_, _, _, _, _, summary) => summary,
          //       orElse: () => const AttendanceSummary(),
          //     );
          //
          //     return _DashboardTodayAttendanceContainer(
          //       title: l10n.totalAbsent,
          //       icon: Icons.arrow_upward,
          //       value: summary.absent.toString(),
          //       descriptionValue: l10n.days,
          //       isLoading: isLoading,
          //       iconBackgroundColor: negativeIconStyle.backgroundColor,
          //       iconForegroundColor: negativeIconStyle.foregroundColor,
          //     );
          //   },
          // ),
          // BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
          //   builder: (context, state) {
          //     final isLoading = state.maybeWhen(
          //       loading: (_, _) => true,
          //       orElse: () => false,
          //     );
          //     final summary = state.maybeWhen(
          //       success: (_, _, _, _, _, summary) => summary,
          //       orElse: () => const AttendanceSummary(),
          //     );
          //
          //     return _DashboardTodayAttendanceContainer(
          //       title: l10n.totalPresent,
          //       icon: Icons.today,
          //       value: summary.present.toString(),
          //       descriptionValue: l10n.days,
          //       crossAxisAlignment: .end,
          //       isLoading: isLoading,
          //       iconBackgroundColor: positiveIconStyle.backgroundColor,
          //       iconForegroundColor: positiveIconStyle.foregroundColor,
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}

typedef _DashboardAttendanceIconStyle = ({
  Color backgroundColor,
  Color foregroundColor,
});

String? _formatNullableTime(DateTime? time, String locale) {
  if (time == null) return null;

  return DateFormat('HH:mm', locale).format(time.toLocal());
}

class _DashboardTodayAttendanceContainer extends StatelessWidget {
  const _DashboardTodayAttendanceContainer({
    required this.title,
    this.value,
    this.descriptionValue,
    this.crossAxisAlignment = .start,
    required this.icon,
    required this.isLoading,
    this.iconBackgroundColor,
    this.iconForegroundColor,
  });

  final String title;
  final String? value;
  final String? descriptionValue;
  final CrossAxisAlignment crossAxisAlignment;
  final IconData icon;
  final bool isLoading;
  final Color? iconBackgroundColor;
  final Color? iconForegroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppContainer(
      margin: EdgeInsets.zero,
      aspectRatio: 1.4,
      elevation: 0,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colorScheme.surfaceContainerHighest,
          offset: const Offset(5, 5),
        ),
      ],
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: .center,
        mainAxisSize: .min,
        children: [
          Row(
            crossAxisAlignment: .center,
            children: [
              AppIconContainer(
                icon: icon,
                backgroundColor: iconBackgroundColor,
                foregroundColor: iconForegroundColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall!.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: .bold,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisSize: .min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: .end,
            children: [
              Flexible(
                child:
                    Text(
                      value ?? "--:--",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineSmall!.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: .bold,
                      ),
                    ).toShimmer(
                      context,
                      isLoading: isLoading,
                      width: 56,
                      height: 24,
                    ),
              ),
              if (descriptionValue != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    descriptionValue!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
