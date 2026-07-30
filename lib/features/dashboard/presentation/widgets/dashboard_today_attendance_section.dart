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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final Color successColor = AppColors.of(context).success;
    final Color checkOutColor = AppColors.of(context).checkOut;
    final _DashboardAttendanceIconStyle positiveIconStyle = (
      backgroundColor: successColor.withValues(alpha: 0.18),
      foregroundColor: successColor,
    );
    final _DashboardAttendanceIconStyle checkOutIconStyle = (
      backgroundColor: checkOutColor.withValues(alpha: 0.14),
      foregroundColor: checkOutColor,
    );
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final DateTime now = DateTime.now();
    final locale = Localizations.localeOf(context).toString();

    return AppSliverGroup(
      title: l10n.dailyAttendance,
      titleStyle: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface),
      action: AppChipContainer.outlined(
        value: DateFormat.yMMMMEEEEd(locale).format(now),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: .stretch,
          children: [
            Expanded(
              child: BlocBuilder<DailyAttendanceBloc, DailyAttendanceState>(
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
                    value: _formatNullableTime(
                      dailyAttendance?.jamCheckIn,
                      locale,
                    ),
                    isLoading: isLoading,
                    iconBackgroundColor: positiveIconStyle.backgroundColor,
                    iconForegroundColor: positiveIconStyle.foregroundColor,
                  );
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<DailyAttendanceBloc, DailyAttendanceState>(
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
                    iconBackgroundColor: checkOutIconStyle.backgroundColor,
                    iconForegroundColor: checkOutIconStyle.foregroundColor,
                  );
                },
              ),
            ),
          ].separatedBy(8.w),
        ),
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return AppFramedContainer(
      backgroundColor: colorScheme.surface,
      margin: .zero,
      gap: .zero,
      elevation: 0,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: .center,
        mainAxisSize: .min,
        children: [
          Row(
            mainAxisSize: .min,
            crossAxisAlignment: .center,
            children: [
              AppIconContainer(
                icon: icon,
                backgroundColor: iconBackgroundColor,
                foregroundColor: iconForegroundColor,
              ).toShimmer(
                context,
                isLoading: isLoading,
                borderRadius: .circular(24),
              ),
              Text(
                title,
                style: textTheme.titleSmall!.copyWith(
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
              ).toShimmer(
                context,
                isLoading: isLoading,
                width: 80,
                height: 16,
                borderRadius: .circular(24),
              ),
            ].separatedBy(16.w),
          ),
          Row(
            mainAxisSize: .min,
            mainAxisAlignment: .end,
            crossAxisAlignment: .end,
            children: [
              Flexible(
                child:
                    Text(
                      value ?? "--:--",
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: textTheme.titleLarge!.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ).toShimmer(
                      context,
                      isLoading: isLoading,
                      width: 80,
                      height: 16,
                      borderRadius: .circular(24),
                    ),
              ),
              if (descriptionValue != null) ...[
                8.w,
                Flexible(
                  child:
                      Text(
                        descriptionValue!,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ).toShimmer(
                        context,
                        isLoading: isLoading,
                        width: 24,
                        height: 16,
                        borderRadius: .circular(24),
                      ),
                ),
              ],
            ],
          ),
        ].separatedBy(16.h),
      ),
    );
  }
}
