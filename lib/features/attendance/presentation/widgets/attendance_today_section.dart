// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../../domain/attendance_rules.dart';
import '../../domain/entities/attendance_entity/attendance_entity.dart';
import '../bloc/daily_attendance_bloc/daily_attendance_bloc.dart';
import 'attendance_qr_bottom_sheet.dart';

class AttendanceTodaySection extends StatefulWidget {
  const AttendanceTodaySection({super.key, this.now = DateTime.now});

  /// Clock seam for tests — pins "now" instead of the real wall clock.
  final DateTime Function() now;

  @override
  State<AttendanceTodaySection> createState() => _AttendanceTodaySectionState();
}

class _AttendanceTodaySectionState extends State<AttendanceTodaySection> {
  Timer? _tickTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();

    _now = widget.now();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = widget.now());
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isParent = context.read<SessionBloc>().state.maybeWhen(
      authenticated: (_, role) => role == UserRole.parent,
      orElse: () => false,
    );

    return BlocConsumer<DailyAttendanceBloc, DailyAttendanceState>(
      listener: (context, state) => state.whenOrNull(
        failure: (failure) =>
            AppToast.error(context, failure.localizedMessage(l10n)),
      ),
      builder: (context, state) {
        return state.maybeWhen(
          failure: (_) => AppEmptyStateSliver(
            icon: Icons.wifi_off_rounded,
            title: l10n.attendanceTodayLoadFailedTitle,
            message: l10n.attendanceTodayLoadFailedSubtitle,
          ),
          emptyAttendance: () {
            final isWeekday = _now.weekday <= DateTime.friday;

            return AppEmptyStateSliver(
              icon: isWeekday
                  ? Icons.hourglass_empty_rounded
                  : Icons.weekend_outlined,
              title: isWeekday
                  ? (isParent
                        ? l10n.attendanceNoDataWeekdayTitleParent
                        : l10n.attendanceNoDataWeekdayTitle)
                  : (isParent
                        ? l10n.attendanceNoScheduleTitleParent
                        : l10n.attendanceNoScheduleTitle),
              message: isWeekday
                  ? (isParent
                        ? l10n.attendanceNoDataWeekdaySubtitleParent
                        : l10n.attendanceNoDataWeekdaySubtitle)
                  : (isParent
                        ? l10n.attendanceNoScheduleSubtitleParent
                        : l10n.attendanceNoScheduleSubtitle),
            );
          },
          orElse: () => SliverPadding(
            padding: const .all(16),
            sliver: SliverToBoxAdapter(
              child: _AttendanceTodayCard(
                state: state,
                now: _now,
                l10n: l10n,
                isParent: isParent,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AttendanceTodayCard extends StatelessWidget {
  const _AttendanceTodayCard({
    required this.state,
    required this.now,
    required this.l10n,
    required this.isParent,
  });

  final DailyAttendanceState state;
  final DateTime now;
  final AppLocalizations l10n;
  final bool isParent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);
    final entity = state.maybeWhen(
      success: (dailyAttendance) => dailyAttendance,
      orElse: () => null,
    );
    final action = isLoading ? null : resolveAttendanceQrAction(entity, now);
    final buttonContent = _buttonContent(action);
    final statusContent = _statusContent(context, entity);

    return AppFramedContainer(
      backgroundColor: colorScheme.surface,
      gap: .zero,
      margin: .zero,
      elevation: 0,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                _timeLabel(entity?.jamCheckIn),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ).toShimmer(
                context,
                isLoading: isLoading,
                width: 48,
                height: 20,
                borderRadius: .circular(24),
              ),
              Text(
                '${_clockLabel(now)} ${l10n.westernIndonesiaTime}',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _timeLabel(entity?.jamCheckOut),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ).toShimmer(
                context,
                isLoading: isLoading,
                width: 48,
                height: 20,
                borderRadius: .circular(24),
              ),
            ],
          ),
          16.h,
          if (isParent)
            Align(
              child:
                  AppChipContainer(
                    value: isLoading
                        ? l10n.attendanceButtonLoading
                        : statusContent.label,
                    backgroundColor: statusContent.color.withValues(
                      alpha: 0.14,
                    ),
                    foregroundColor: statusContent.color,
                  ).toShimmer(
                    context,
                    isLoading: isLoading,
                    width: 100,
                    height: 28,
                    borderRadius: .circular(24),
                  ),
            )
          else
            AppButton(
              onPressed: isLoading || !buttonContent.enabled
                  ? null
                  : () => showAttendanceQrSheet(context),
              child: Text(
                isLoading ? l10n.attendanceButtonLoading : buttonContent.label,
              ),
            ),
        ],
      ),
    );
  }

  ({String label, Color color}) _statusContent(
    BuildContext context,
    AttendanceEntity? entity,
  ) {
    final appColors = AppColors.of(context);

    if (entity?.jamCheckIn == null) {
      return (
        label: l10n.attendanceParentStatusNotCheckedIn,
        color: appColors.warning,
      );
    }
    if (entity!.jamCheckOut == null) {
      return (
        label: l10n.attendanceParentStatusCheckedIn,
        color: appColors.success,
      );
    }
    return (
      label: l10n.attendanceParentStatusCheckedOut,
      color: appColors.checkOut,
    );
  }

  ({String label, bool enabled}) _buttonContent(AttendanceQrAction? action) {
    return switch (action) {
      null => (label: '', enabled: false),
      .checkIn => (label: l10n.attendanceCheckInAction, enabled: true),
      .alreadyCheckedIn => (
        label: l10n.attendanceAlreadyCheckedIn,
        enabled: false,
      ),
      .checkOut => (label: l10n.attendanceCheckOutAction, enabled: true),
      .done => (label: l10n.attendanceDone, enabled: false),
    };
  }

  String _timeLabel(DateTime? dateTime) =>
      dateTime == null ? '--:--' : dateTime.toLocal().toHourMinuteFormat();

  String _clockLabel(DateTime now) => now.toHourMinuteSecondFormat();
}
