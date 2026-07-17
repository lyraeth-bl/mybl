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
import '../../domain/entities/attendance_entity/attendance_entity.dart';
import '../bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';

class AttendanceFilteredSection extends StatefulWidget {
  const AttendanceFilteredSection({super.key});

  @override
  State<AttendanceFilteredSection> createState() =>
      AttendanceFilteredSectionState();
}

class AttendanceFilteredSectionState extends State<AttendanceFilteredSection> {
  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();

    final today = DateUtils.dateOnly(DateTime.now());
    _fromDate = today.subtract(const Duration(days: 6));
    _toDate = today;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: l10n.attendanceLog,
      titleStyle: textTheme.titleMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      action: Tooltip(
        message: l10n.attendanceDateFilter,
        child: AppChipContainer(
          onTap: _showPresetSheet,
          child: const Icon(Icons.tune_rounded, size: 18),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: BlocBuilder<MonthlyAttendanceBloc, MonthlyAttendanceState>(
        buildWhen: (prev, curr) {
          final prevData = (
            list: prev.maybeWhen(
              success: (_, _, monthlyAttendance, _, _, _) => monthlyAttendance,
              orElse: () => const <AttendanceEntity>[],
            ),
            isLoading: prev.maybeWhen(
              loading: (_, _) => true,
              orElse: () => false,
            ),
          );
          final currData = (
            list: curr.maybeWhen(
              success: (_, _, monthlyAttendance, _, _, _) => monthlyAttendance,
              orElse: () => const <AttendanceEntity>[],
            ),
            isLoading: curr.maybeWhen(
              loading: (_, _) => true,
              orElse: () => false,
            ),
          );

          return prevData != currData;
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: (_, _) => true,
            orElse: () => false,
          );
          final monthlyAttendance = state.maybeWhen(
            success: (_, _, monthlyAttendance, _, _, _) => monthlyAttendance,
            orElse: () => const <AttendanceEntity>[],
          );
          final filteredAttendance = _filteredAttendance(monthlyAttendance);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AttendanceFilterBar(
                fromDate: _fromDate,
                toDate: _toDate,
                onFromDatePressed: () => _pickDate(isFromDate: true),
                onToDatePressed: () => _pickDate(isFromDate: false),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                ...List.generate(3, (index) {
                  final shape = index.makeVerticalGoogleShape(2);

                  return _AttendanceLogContainer.loading(shape: shape);
                })
              else if (filteredAttendance.isEmpty)
                _AttendanceMessageContainer(
                  icon: Icons.event_busy_outlined,
                  message: l10n.noAttendanceData,
                )
              else
                ...filteredAttendance.indexed.map((entry) {
                  final attendance = entry.$2;
                  final shape = entry.$1.makeVerticalGoogleShape(
                    filteredAttendance.length - 1,
                  );

                  return _AttendanceLogContainer(
                    attendance: attendance,
                    shape: shape,
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  List<AttendanceEntity> _filteredAttendance(List<AttendanceEntity> list) {
    final start = DateUtils.dateOnly(_fromDate);
    final end = DateUtils.dateOnly(_toDate);

    final filtered = list.where((attendance) {
      final date = DateUtils.dateOnly(attendance.tanggal);

      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();

    filtered.sort((a, b) => b.tanggal.compareTo(a.tanggal));

    return filtered;
  }

  Future<void> _pickDate({required bool isFromDate}) async {
    final now = DateTime.now();
    final initialDate = isFromDate ? _fromDate : _toDate;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );

    if (selectedDate == null || !mounted) return;

    setState(() {
      final date = DateUtils.dateOnly(selectedDate);
      if (isFromDate) {
        _fromDate = date;
        if (_fromDate.isAfter(_toDate)) _toDate = _fromDate;
      } else {
        _toDate = date;
        if (_toDate.isBefore(_fromDate)) _fromDate = _toDate;
      }
    });
  }

  Future<void> _showPresetSheet() async {
    final selectedRange = await showModalBottomSheet<_AttendanceDateRange>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _AttendancePresetSheet(),
    );

    if (selectedRange == null || !mounted) return;

    setState(() {
      _fromDate = selectedRange.fromDate;
      _toDate = selectedRange.toDate;
    });
  }
}

class _AttendanceFilterBar extends StatelessWidget {
  const _AttendanceFilterBar({
    required this.fromDate,
    required this.toDate,
    required this.onFromDatePressed,
    required this.onToDatePressed,
  });

  final DateTime fromDate;
  final DateTime toDate;
  final VoidCallback onFromDatePressed;
  final VoidCallback onToDatePressed;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy', locale);

    return Row(
      children: [
        Expanded(
          child: _DateFilterButton(
            label: l10n.fromDate,
            value: dateFormat.format(fromDate),
            onTap: onFromDatePressed,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _DateFilterButton(
            label: l10n.toDate,
            value: dateFormat.format(toDate),
            onTap: onToDatePressed,
            crossAxisAlignment: .end,
          ),
        ),
      ],
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.label,
    required this.value,
    required this.onTap,
    this.crossAxisAlignment = .start,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppFramedContainer(
      margin: EdgeInsets.zero,
      gap: EdgeInsets.zero,
      onTap: onTap,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      innerBorderRadius: BorderRadius.circular(16),
      innerPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: .min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: .bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendancePresetSheet extends StatelessWidget {
  const _AttendancePresetSheet();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final today = DateUtils.dateOnly(DateTime.now());
    final firstDateOfMonth = DateTime(today.year, today.month);
    final presets = <({String label, _AttendanceDateRange range})>[
      (label: l10n.today, range: _AttendanceDateRange(today, today)),
      (
        label: l10n.yesterday,
        range: _AttendanceDateRange(
          today.subtract(const Duration(days: 1)),
          today.subtract(const Duration(days: 1)),
        ),
      ),
      (
        label: l10n.last3Days,
        range: _AttendanceDateRange(
          today.subtract(const Duration(days: 2)),
          today,
        ),
      ),
      (
        label: l10n.last7Days,
        range: _AttendanceDateRange(
          today.subtract(const Duration(days: 6)),
          today,
        ),
      ),
      (
        label: l10n.thisMonth,
        range: _AttendanceDateRange(firstDateOfMonth, today),
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.attendanceDateFilter,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: .bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            ...presets.map(
              (preset) => AppContainer(
                elevation: 0,
                backgroundColor: colorScheme.surfaceContainer,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: BorderRadius.circular(16),
                padding: EdgeInsets.zero,
                child: ListTile(
                  title: Text(preset.label),
                  onTap: () => Navigator.of(context).pop(preset.range),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceDateRange {
  const _AttendanceDateRange(this.fromDate, this.toDate);

  final DateTime fromDate;
  final DateTime toDate;
}

class _AttendanceLogContainer extends StatelessWidget {
  const _AttendanceLogContainer({required this.attendance, required this.shape})
    : isLoading = false;

  const _AttendanceLogContainer.loading({required this.shape})
    : attendance = null,
      isLoading = true;

  final AttendanceEntity? attendance;
  final ShapeBorder shape;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('EEEE, d MMM yyyy', locale);
    final timeFormat = DateFormat('HH:mm', locale);
    final entity = attendance;
    final statusStyle = _attendanceStatusStyle(context, entity?.status);
    final checkIn = entity?.jamCheckIn;
    final checkOut = entity?.jamCheckOut;

    final effectiveBorderRadius = shape is RoundedRectangleBorder
        ? (shape as RoundedRectangleBorder).borderRadius
        : const BorderRadius.all(Radius.circular(16));

    return AppFramedContainer(
      margin: const EdgeInsets.symmetric(vertical: 2),
      gap: EdgeInsets.zero,
      borderRadius: effectiveBorderRadius,
      innerBorderRadius: effectiveBorderRadius,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppIconContainer(
            padding: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            icon: statusStyle.icon,
            backgroundColor: statusStyle.backgroundColor,
            foregroundColor: statusStyle.foregroundColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entity == null ? '' : dateFormat.format(entity.tanggal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: .bold,
                  ),
                ).toShimmer(
                  context,
                  isLoading: isLoading,
                  width: 120,
                  height: 12,
                ),
                const SizedBox(height: 16),
                Text(
                  '${_timeLabel(checkIn, timeFormat)}     -     ${_timeLabel(checkOut, timeFormat)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ).toShimmer(
                  context,
                  isLoading: isLoading,
                  width: 96,
                  height: 12,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppChipContainer(
                value: _attendanceStatusLabel(l10n, entity?.status),
                backgroundColor: statusStyle.backgroundColor,
                foregroundColor: statusStyle.foregroundColor,
              ).toShimmer(
                context,
                isLoading: isLoading,
                width: 72,
                height: 28,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 8),
              Text(
                _durationLabel(l10n, checkIn, checkOut),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ).toShimmer(context, isLoading: isLoading, width: 48, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceMessageContainer extends StatelessWidget {
  const _AttendanceMessageContainer({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppFramedContainer(
      margin: EdgeInsets.zero,
      gap: EdgeInsets.zero,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      innerBorderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          AppIconContainer(
            padding: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            icon: icon,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: .bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

({Color backgroundColor, Color foregroundColor, IconData icon})
_attendanceStatusStyle(BuildContext context, String? status) {
  final colorScheme = Theme.of(context).colorScheme;
  final appColors = AppColors.of(context);

  return switch (status) {
    'Hadir' => (
      backgroundColor: appColors.success.withValues(alpha: 0.15),
      foregroundColor: appColors.success,
      icon: Icons.check_circle_rounded,
    ),
    'Terlambat' => (
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      icon: Icons.watch_later_rounded,
    ),
    'Belum Check-In' => (
      backgroundColor: colorScheme.errorContainer,
      foregroundColor: colorScheme.onErrorContainer,
      icon: Icons.cancel_rounded,
    ),
    _ => (
      backgroundColor: appColors.warning.withValues(alpha: 0.15),
      foregroundColor: appColors.warning,
      icon: Icons.info_rounded,
    ),
  };
}

String _attendanceStatusLabel(AppLocalizations l10n, String? status) {
  return switch (status) {
    'Hadir' => l10n.present,
    'Terlambat' => l10n.late,
    'Belum Check-In' => l10n.absent,
    null => '',
    _ => l10n.excused,
  };
}

String _timeLabel(DateTime? dateTime, DateFormat formatter) {
  if (dateTime == null) return '--:--';

  return formatter.format(dateTime.toLocal());
}

String _durationLabel(
  AppLocalizations l10n,
  DateTime? checkIn,
  DateTime? checkOut,
) {
  if (checkIn == null || checkOut == null) return '--:--';

  final duration = checkOut.difference(checkIn);
  if (duration.inMinutes <= 0) return '--:--';

  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(Duration.minutesPerHour);

  if (hours == 0) return l10n.scheduleDurationMinutes(minutes);

  return l10n.attendanceDurationHoursMinutes(hours, minutes);
}
