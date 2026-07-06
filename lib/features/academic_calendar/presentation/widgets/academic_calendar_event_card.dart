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

    return AppFramedContainer(
      margin: const EdgeInsets.only(bottom: 8),
      gap: .zero,
      elevation: 0,
      child: Row(
        crossAxisAlignment: .start,
        children: [
          _EventDateBadge(month: monthLabel, day: dayLabel),
          16.w,
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  event.judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                8.h,
                _EventInlineMeta(
                  icon: Icons.schedule_rounded,
                  value: _formatEventRange(event, locale),
                ),
                if (event.keterangan.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    event.keterangan,
                    maxLines: 2,
                    overflow: .ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          8.w,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 84),
            child: AppChipContainer(
              value: academicCalendarStatusLabel(
                AppLocalizations.of(context)!,
                status,
              ).toUpperCase(),
              backgroundColor: statusBackgroundColor,
              foregroundColor: statusForegroundColor,
              textStyle: textTheme.labelSmall,
              textAlign: .center,
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
    return AppFramedContainer(
      margin: const EdgeInsets.only(bottom: 8),
      gap: EdgeInsets.zero,
      elevation: 0,
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
          color: colorScheme.primaryContainer,
          borderRadius: .circular(8),
        ),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(
              month,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            Text(
              day,
              style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
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
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: .ellipsis,
            style: textTheme.bodySmall?.copyWith(
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
