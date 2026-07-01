// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/presentation/bloc/parent_daily_attendance_bloc/parent_daily_attendance_bloc.dart';
import '../../../user/domain/entities/child_entity/child_entity.dart';
import '../../../user/presentation/bloc/parent_bloc/parent_bloc.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ParentDailyAttendanceBloc>(
      create: (_) => di<ParentDailyAttendanceBloc>(),
      child: const _ParentDashboardView(),
    );
  }
}

class _ParentDashboardView extends StatefulWidget {
  const _ParentDashboardView();

  @override
  State<_ParentDashboardView> createState() => _ParentDashboardViewState();
}

class _ParentDashboardViewState extends State<_ParentDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParentDailyAttendanceBloc>().add(
        const ParentDailyAttendanceEvent.dailyAttendanceRequested(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ParentBloc, ParentState>(
      builder: (context, state) {
        final record = state.maybeWhen(
          ready: (parent, children, selectedChild) => (
            nama: parent.nama,
            child: selectedChild,
            hasMultipleChildren: children.length > 1,
            children: children,
          ),
          orElse: () => (
            nama: '',
            child: null,
            hasMultipleChildren: false,
            children: <ChildEntity>[],
          ),
        );

        return Scaffold(
          appBar: const _ParentDashboardAppTopBar(),
          backgroundColor: colorScheme.surfaceContainer,
          body: _ParentDashboardBody(
            childEntity: record.child,
            children: record.children,
          ),
        );
      },
    );
  }
}

class _ParentDashboardAppTopBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ParentDashboardAppTopBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(
      backgroundColor: colorScheme.surfaceContainerLow,
      toolbarHeight: 80,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _WavingHands(colorScheme: colorScheme),
              _GreetingAndName(
                colorScheme: colorScheme,
                l10n: l10n,
                textTheme: textTheme,
              ),
            ].separatedBy(8.w),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _ParentDashboardBody extends StatelessWidget {
  const _ParentDashboardBody({this.childEntity, this.children});

  final List<ChildEntity>? children;
  final ChildEntity? childEntity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardOutlineCard(
              onTap: () => {},
              title: Text(
                (children?.length ?? 0) > 1
                    ? l10n.parentChildSelectorMultipleChildren
                    : l10n.parentChildSelectorSingleChild,
              ),
              child: children == null || children!.isEmpty
                  ? _ChildrenEmptyState(l10n: l10n)
                  : Column(
                      children: children!
                          .map(
                            (child) => _ChildrenDetail(
                              classRoom: child.kelas,
                              name: child.nama.capitalizeEveryWord,
                              nis: child.nis,
                            ),
                          )
                          .toList(),
                    ),
            ),
            24.h,
            _ParentDailyAttendanceCard(childEntity: childEntity),
          ],
        ),
      ),
    );
  }
}

class _ParentDailyAttendanceCard extends StatelessWidget {
  const _ParentDailyAttendanceCard({this.childEntity});

  final ChildEntity? childEntity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<ParentDailyAttendanceBloc, ParentDailyAttendanceState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          initial: () => true,
          loading: () => true,
          orElse: () => false,
        );
        final isFailure = state.maybeWhen(
          failure: (_) => true,
          orElse: () => false,
        );
        final isEmptyAttendance = state.maybeWhen(
          emptyAttendance: () => true,
          orElse: () => false,
        );
        final dailyAttendance = state.whenOrNull(
          success: (data) => data,
        );

        return _DashboardOutlineCard(
          onTap: () => {},
          innerPadding: const EdgeInsets.all(16),
          title: Text(l10n.dailyAttendance),
          trailing: AppChipContainer(
            value: DateFormat.yMMMMEEEEd(locale).format(now),
            backgroundColor: Colors.transparent,
            foregroundColor: colorScheme.onSurfaceVariant,
            side: BorderSide(color: colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (childEntity != null) ...[
                16.h,
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    4.w,
                    Text(
                      childEntity!.nama.capitalizeEveryWord,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    4.w,
                    Text(
                      '·',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    4.w,
                    Text(
                      childEntity!.kelas,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              16.h,
              if (isFailure)
                _AttendanceErrorState(
                  onRetry: () => context
                      .read<ParentDailyAttendanceBloc>()
                      .add(
                        const ParentDailyAttendanceEvent
                            .dailyAttendanceRequested(),
                      ),
                )
              else if (isEmptyAttendance)
                _AttendanceEmptyState(message: l10n.noAttendanceData)
              else
                _AttendanceTimesRow(
                  checkInTime: _formatTime(
                    dailyAttendance?.jamCheckIn,
                    locale,
                  ),
                  checkOutTime: _formatTime(
                    dailyAttendance?.jamCheckOut,
                    locale,
                  ),
                  timezone: l10n.westernIndonesiaTime,
                  isLoading: isLoading,
                  checkInLabel: l10n.checkIn,
                  checkOutLabel: l10n.checkOut,
                ),
              if (dailyAttendance?.status != null) ...[
                16.h,
                Row(
                  children: [
                    Text(
                      l10n.status,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    _AttendanceStatusChip(status: dailyAttendance!.status),
                  ],
                ),
              ],
              8.h,
            ],
          ),
        );
      },
    );
  }

  String? _formatTime(DateTime? time, String locale) {
    if (time == null) return null;
    return DateFormat('HH:mm', locale).format(time.toLocal());
  }
}

class _AttendanceErrorState extends StatelessWidget {
  const _AttendanceErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Icon(Icons.error_outline, size: 16, color: colorScheme.error),
        8.w,
        Expanded(
          child: Text(
            l10n.dioServerError,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        8.w,
        TextButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
      ],
    );
  }
}

class _AttendanceEmptyState extends StatelessWidget {
  const _AttendanceEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        8.w,
        Text(
          message,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ChildrenEmptyState extends StatelessWidget {
  const _ChildrenEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(
            Icons.people_outline,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          8.w,
          Text(
            l10n.noData,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTimesRow extends StatelessWidget {
  const _AttendanceTimesRow({
    required this.checkInTime,
    required this.checkOutTime,
    required this.timezone,
    required this.isLoading,
    required this.checkInLabel,
    required this.checkOutLabel,
  });

  final String? checkInTime;
  final String? checkOutTime;
  final String timezone;
  final bool isLoading;
  final String checkInLabel;
  final String checkOutLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _CompactTimeCell(
              label: checkInLabel,
              icon: Icons.login_rounded,
              time: checkInTime,
              timezone: timezone,
              isLoading: isLoading,
              iconBackgroundColor: AppColors.of(
                context,
              ).success.withValues(alpha: 0.18),
              iconForegroundColor: AppColors.of(context).success,
            ),
          ),
          VerticalDivider(
            width: 24,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),
          Expanded(
            child: _CompactTimeCell(
              label: checkOutLabel,
              icon: Icons.logout_rounded,
              time: checkOutTime,
              timezone: timezone,
              isLoading: isLoading,
              iconBackgroundColor: colorScheme.error.withValues(alpha: 0.14),
              iconForegroundColor: colorScheme.error,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactTimeCell extends StatelessWidget {
  const _CompactTimeCell({
    required this.label,
    required this.icon,
    required this.time,
    required this.timezone,
    required this.isLoading,
    required this.iconBackgroundColor,
    required this.iconForegroundColor,
    this.alignEnd = false,
  });

  final String label;
  final IconData icon;
  final String? time;
  final String timezone;
  final bool isLoading;
  final Color iconBackgroundColor;
  final Color iconForegroundColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alignEnd) ...[
              AppIconContainer(
                icon: icon,
                iconSize: 18,
                backgroundColor: iconBackgroundColor,
                foregroundColor: iconForegroundColor,
              ),
              8.w,
            ],
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (alignEnd) ...[
              8.w,
              AppIconContainer(
                icon: icon,
                iconSize: 18,
                backgroundColor: iconBackgroundColor,
                foregroundColor: iconForegroundColor,
              ),
            ],
          ],
        ),
        8.h,
        Text(
          time ?? '--:--',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleLarge!.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ).toShimmer(context, isLoading: isLoading, width: 64, height: 22),
        4.h,
        Text(
          timezone,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AttendanceStatusChip extends StatelessWidget {
  const _AttendanceStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (bgColor, fgColor) = switch (status) {
      'Hadir' => (
        AppColors.of(context).success.withValues(alpha: 0.18),
        AppColors.of(context).success,
      ),
      'Terlambat' => (
        colorScheme.tertiary.withValues(alpha: 0.18),
        colorScheme.tertiary,
      ),
      'Belum Check-In' => (
        colorScheme.error.withValues(alpha: 0.14),
        colorScheme.error,
      ),
      _ => (
        colorScheme.secondary.withValues(alpha: 0.14),
        colorScheme.secondary,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: textTheme.labelMedium?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DashboardOutlineCard extends StatelessWidget {
  const _DashboardOutlineCard({
    this.onTap,
    this.innerPadding,
    this.trailing,
    required this.title,
    required this.child,
  });

  final EdgeInsetsGeometry? innerPadding;
  final VoidCallback? onTap;
  final Widget title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppFramedContainer(
      onTap: onTap,
      margin: EdgeInsets.zero,
      innerPadding: innerPadding ?? EdgeInsets.zero,
      gap: EdgeInsets.zero,
      innerColor: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      innerBorderRadius: BorderRadius.circular(12),
      title: title,
      trailing: trailing,
      child: child,
    );
  }
}

class _WavingHands extends StatelessWidget {
  const _WavingHands({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final icon = Icon(Icons.waving_hand, color: colorScheme.onSurface);
    if (disableAnimations) return icon;
    return icon
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .rotate(begin: -0.1, end: 0.05, duration: 3.seconds);
  }
}

class _GreetingAndName extends StatelessWidget {
  const _GreetingAndName({
    required this.colorScheme,
    required this.l10n,
    required this.textTheme,
  });

  final AppLocalizations l10n;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 11) return l10n.goodMorning;
    if (hour < 15) return l10n.goodAfternoon;
    if (hour < 18) return l10n.goodEvening;
    return l10n.goodNight;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(l10n),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          BlocSelector<ParentBloc, ParentState, String>(
            selector: (state) => state.maybeWhen(
              ready: (parent, _, _) => parent.nama,
              orElse: () => '',
            ),
            builder: (context, name) {
              return Text(
                l10n.parentGreetingName(name.capitalizeEveryWord),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              );
            },
          ),
        ].separatedBy(4.h),
      ),
    );
  }
}

class _ChildrenDetail extends StatelessWidget {
  const _ChildrenDetail({
    required this.name,
    required this.nis,
    required this.classRoom,
  });

  final String name;
  final String nis;
  final String classRoom;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: AppProfilePicture(
        backgroundColor: colorScheme.inverseSurface,
        foregroundColor: colorScheme.onInverseSurface,
        radius: 22,
      ),
      title: Text(
        name,
        style: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            Icon(
              Icons.badge_outlined,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            Text(nis),
            Text('-'),
            Icon(
              Icons.school_outlined,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            Text(classRoom),
          ].separatedBy(4.w),
        ),
      ),
    );
  }
}
