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
import '../../../attendance/presentation/bloc/parent_daily_attendance_bloc/parent_daily_attendance_bloc.dart';
import '../../../user/presentation/bloc/parent_bloc/parent_bloc.dart';

class ParentDashboardDailyAttendanceSection extends StatelessWidget {
  const ParentDashboardDailyAttendanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final successColor = AppColors.of(context).success;
    final _ParentDashboardAttendanceIconStyle positiveIconStyle = (
      backgroundColor: successColor.withValues(alpha: 0.18),
      foregroundColor: successColor,
    );
    final _ParentDashboardAttendanceIconStyle negativeIconStyle = (
      backgroundColor: colorScheme.error.withValues(alpha: 0.14),
      foregroundColor: colorScheme.error,
    );
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final childName = context.select<ParentBloc, String>(
      (bloc) => bloc.state.maybeWhen(
        ready: (_, _, selectedChild) =>
            selectedChild?.nama.capitalizeEveryWord ?? '',
        orElse: () => '',
      ),
    );

    return AppSliverGroup(
      title: childName.isEmpty
          ? l10n.dailyAttendance
          : l10n.parentDailyAttendanceTitle(
              childName.takeFirstWordAndCapitalize,
            ),
      titleStyle: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      action: AppChipContainer(
        value: DateFormat.yMMMMEEEEd(locale).format(now),
      ),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.5,
        children: [
          BlocBuilder<ParentDailyAttendanceBloc, ParentDailyAttendanceState>(
            builder: (context, state) {
              final isLoading = state.maybeWhen(
                initial: () => true,
                loading: () => true,
                orElse: () => false,
              );
              final dailyAttendance = state.whenOrNull(
                success: (dailyAttendance) => dailyAttendance,
              );

              return _ParentDashboardTodayAttendanceContainer(
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
          BlocBuilder<ParentDailyAttendanceBloc, ParentDailyAttendanceState>(
            builder: (context, state) {
              final isLoading = state.maybeWhen(
                initial: () => true,
                loading: () => true,
                orElse: () => false,
              );
              final dailyAttendance = state.whenOrNull(
                success: (dailyAttendance) => dailyAttendance,
              );

              return _ParentDashboardTodayAttendanceContainer(
                title: l10n.checkOut,
                icon: Icons.call_made,
                descriptionValue: l10n.westernIndonesiaTime,
                value: _formatNullableTime(
                  dailyAttendance?.jamCheckOut,
                  locale,
                ),
                crossAxisAlignment: CrossAxisAlignment.end,
                isLoading: isLoading,
                iconBackgroundColor: negativeIconStyle.backgroundColor,
                iconForegroundColor: negativeIconStyle.foregroundColor,
              );
            },
          ),
        ],
      ),
    );
  }
}

typedef _ParentDashboardAttendanceIconStyle = ({
  Color backgroundColor,
  Color foregroundColor,
});

String? _formatNullableTime(DateTime? time, String locale) {
  if (time == null) return null;

  return DateFormat('HH:mm', locale).format(time.toLocal());
}

class _ParentDashboardTodayAttendanceContainer extends StatelessWidget {
  const _ParentDashboardTodayAttendanceContainer({
    required this.title,
    this.value,
    this.descriptionValue,
    this.crossAxisAlignment = CrossAxisAlignment.start,
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

    return AppFramedContainer(
      gap: .zero,
      innerPadding: .symmetric(horizontal: 16, vertical: 8),
      margin: EdgeInsets.zero,
      aspectRatio: 1.5,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppIconContainer(
                icon: icon,
                backgroundColor: iconBackgroundColor,
                foregroundColor: iconForegroundColor,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: textTheme.titleSmall!.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child:
                    Text(
                      value ?? "--:--",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineSmall!.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
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
