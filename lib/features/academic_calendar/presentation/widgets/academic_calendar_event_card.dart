// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/academic_calendar_entity.dart';
import 'academic_calendar_status.dart';

class AcademicCalendarEventCard extends StatelessWidget {
  const AcademicCalendarEventCard({super.key, required this.event});

  final AcademicCalendarEntity event;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final startDate = DateTime.tryParse(event.tanggalMulai);
    final monthLabel = startDate == null
        ? '-'
        : DateFormat('MMM', locale).format(startDate).toUpperCase();
    final dayLabel = startDate == null ? '-' : '${startDate.day}';
    final status = academicCalendarStatusFromTitle(event.judul);
    final (statusBackgroundColor, statusForegroundColor) =
        academicCalendarStatusColors(context, status);

    return AppContainer(
      margin: const EdgeInsets.only(bottom: 12),
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EventDateBadge(month: monthLabel, day: dayLabel),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _EventInlineMeta(
                  icon: Icons.schedule_rounded,
                  value: _formatEventRange(event, locale),
                ),
                if (event.unit.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _EventInlineMeta(
                    icon: Icons.school_outlined,
                    value: event.unit,
                  ),
                ],
                if (event.keterangan.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    event.keterangan,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 84),
            child: AppChipContainer(
              value: academicCalendarStatusLabel(
                AppLocalizations.of(context)!,
                status,
              ).toUpperCase(),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              backgroundColor: statusBackgroundColor,
              foregroundColor: statusForegroundColor,
              textStyle: textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _formatEventRange(AcademicCalendarEntity event, String locale) {
    final startDate = DateTime.tryParse(event.tanggalMulai);
    final endDate = DateTime.tryParse(event.tanggalSelesai);

    if (startDate == null) return event.tanggalMulai;
    final formatter = DateFormat('d MMM yyyy', locale);
    if (endDate == null || DateUtils.isSameDay(startDate, endDate)) {
      return formatter.format(startDate);
    }

    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }
}

class AcademicCalendarEventLoadingCard extends StatelessWidget {
  const AcademicCalendarEventLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: const EdgeInsets.only(bottom: 12),
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LoadingBox(width: 52, height: 52),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LoadingBox(width: 180, height: 14),
                SizedBox(height: 10),
                _LoadingBox(width: 128, height: 11),
                SizedBox(height: 8),
                _LoadingBox(width: 96, height: 11),
              ],
            ),
          ),
          SizedBox(width: 8),
          _LoadingBox(width: 52, height: 24),
        ],
      ),
    );
  }
}

class AcademicCalendarEventListMessage extends StatelessWidget {
  const AcademicCalendarEventListMessage({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          children: [
            Icon(icon, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventDateBadge extends StatelessWidget {
  const _EventDateBadge({required this.month, required this.day});

  final String month;
  final String day;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox.square(
      dimension: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              month,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              day,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventInlineMeta extends StatelessWidget {
  const _EventInlineMeta({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox({this.width, required this.height});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return const SizedBox().toShimmer(
      context,
      width: width ?? double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
