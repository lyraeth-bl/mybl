// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/attendance_rules.dart';
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

    return BlocConsumer<DailyAttendanceBloc, DailyAttendanceState>(
      listener: (context, state) => state.whenOrNull(
        failure: (failure) =>
            AppToast.error(context, failure.localizedMessage(l10n)),
      ),
      builder: (context, state) {
        return state.maybeWhen(
          failure: (_) => SliverFillRemaining(
            hasScrollBody: false,
            child: _AttendanceEmptyState(
              icon: Icons.wifi_off_rounded,
              title: l10n.attendanceTodayLoadFailedTitle,
              message: l10n.attendanceTodayLoadFailedSubtitle,
            ),
          ),
          emptyAttendance: () => SliverFillRemaining(
            hasScrollBody: false,
            child: _AttendanceEmptyState(
              icon: Icons.weekend_outlined,
              title: l10n.attendanceNoScheduleTitle,
              message: l10n.attendanceNoScheduleSubtitle,
            ),
          ),
          orElse: () => SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: _AttendanceTodayCard(state: state, now: _now, l10n: l10n),
            ),
          ),
        );
      },
    );
  }
}

class _AttendanceEmptyState extends StatelessWidget {
  const _AttendanceEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 36),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTodayCard extends StatelessWidget {
  const _AttendanceTodayCard({
    required this.state,
    required this.now,
    required this.l10n,
  });

  final DailyAttendanceState state;
  final DateTime now;
  final AppLocalizations l10n;

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

    return AppFramedContainer(
      backgroundColor: colorScheme.surface,
      gap: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _timeLabel(entity?.jamCheckIn),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ).toShimmer(context, isLoading: isLoading, width: 48, height: 20),
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
                  fontWeight: FontWeight.bold,
                ),
              ).toShimmer(context, isLoading: isLoading, width: 48, height: 20),
            ],
          ),
          16.h,
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

  ({String label, bool enabled}) _buttonContent(AttendanceQrAction? action) {
    return switch (action) {
      null => (label: '', enabled: false),
      AttendanceQrAction.checkIn => (
        label: l10n.attendanceCheckInAction,
        enabled: true,
      ),
      AttendanceQrAction.alreadyCheckedIn => (
        label: l10n.attendanceAlreadyCheckedIn,
        enabled: false,
      ),
      AttendanceQrAction.checkOut => (
        label: l10n.attendanceCheckOutAction,
        enabled: true,
      ),
      AttendanceQrAction.done => (label: l10n.attendanceDone, enabled: false),
    };
  }

  String _timeLabel(DateTime? dateTime) =>
      dateTime == null ? '--:--' : dateTime.toLocal().toHourMinuteFormat();

  String _clockLabel(DateTime now) => now.toHourMinuteSecondFormat();
}
