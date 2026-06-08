// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/utils/subject_icon_resolver.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/academic_result/academic_result.dart';
import 'academic_result_ui_helpers.dart';

class AcademicResultSubjectListSection extends StatelessWidget {
  const AcademicResultSubjectListSection({
    super.key,
    required this.subjects,
    required this.emptyMessage,
  });

  final List<AcademicResultSubjectView> subjects;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSliverGroup(
      title: l10n.subjectList,
      titleStyle: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      action: AppChipContainer(
        value: l10n.subjectCount(subjects.length),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: subjects.isEmpty
          ? SliverToBoxAdapter(
              child: AcademicResultMessage(
                icon: Icons.menu_book_outlined,
                message: emptyMessage,
              ),
            )
          : SliverList.list(
              children: subjects
                  .map((subject) => _SubjectCard(subject: subject))
                  .toList()
                  .makeListAnimate(),
            ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject});

  final AcademicResultSubjectView subject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final scoreColor = academicResultScoreColor(context, subject.average);

    return AppContainer(
      margin: const EdgeInsets.only(bottom: 12),
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showSubjectDetailSheet(context, subject),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubjectIcon(subjectName: subject.subjectName),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.subjectName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if ((subject.teacherName ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subject.teacherName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.format_list_numbered_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            l10n.assessmentDataCount(subject.totalData),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    academicResultGrade(subject.average),
                    style: textTheme.titleLarge?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  AppChipContainer(
                    value: '${academicResultFormatScore(subject.average)}/100',
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    backgroundColor: scoreColor.withValues(alpha: 0.12),
                    foregroundColor: scoreColor,
                    textStyle: textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppContainer(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(12),
            backgroundColor: colorScheme.surfaceContainer,
            elevation: 0,
            borderRadius: BorderRadius.circular(8),
            child: Text(
              '"${subject.latestDescription}"',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectIcon extends StatelessWidget {
  const _SubjectIcon({required this.subjectName});

  final String subjectName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppIconContainer(
      icon: SubjectIconResolver.resolve(subjectName),
      padding: const EdgeInsets.all(8),
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
    );
  }
}

void _showSubjectDetailSheet(
  BuildContext context,
  AcademicResultSubjectView subject,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.38,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return _SubjectDetailSheet(
            subject: subject,
            scrollController: scrollController,
          );
        },
      );
    },
  );
}

class _SubjectDetailSheet extends StatelessWidget {
  const _SubjectDetailSheet({
    required this.subject,
    required this.scrollController,
  });

  final AcademicResultSubjectView subject;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          AppContainer(
            margin: EdgeInsets.zero,
            backgroundColor: colorScheme.surfaceContainerLow,
            elevation: 0,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.subjectName,
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if ((subject.teacherName ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.teacher}: ${subject.teacherName}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _AverageBadge(value: subject.average),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppContainer(
            margin: EdgeInsets.zero,
            backgroundColor: colorScheme.surfaceContainerLow,
            elevation: 0,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  child: _SimpleMetric(
                    label: l10n.average,
                    value: academicResultFormatScore(subject.average),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SimpleMetric(
                    label: l10n.totalAssessment,
                    value: '${subject.totalData}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (subject.results.isEmpty)
            AcademicResultMessage(
              icon: Icons.fact_check_outlined,
              message: l10n.noData,
            )
          else
            ...subject.results
                .map((result) => _ResultDetailCard(result: result))
                .toList()
                .makeListAnimate(),
        ],
      ),
    );
  }
}

class _ResultDetailCard extends StatelessWidget {
  const _ResultDetailCard({required this.result});

  final AcademicResultEntity result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();

    return AppContainer(
      margin: const EdgeInsets.only(bottom: 10),
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  result.aspekNilai,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AppChipContainer(
                value: '${result.nilai}/100',
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailLine(
            icon: Icons.calendar_month_outlined,
            label: l10n.date,
            value: DateFormat.yMMMd(locale).format(result.tanggal),
          ),
          _DetailLine(
            icon: Icons.category_outlined,
            label: l10n.scoreType,
            value: result.jenisNilai,
          ),
          _DetailLine(
            icon: Icons.format_list_numbered_rounded,
            label: l10n.scoreSequence,
            value: '${result.nilaiKe}',
          ),
          _DetailLine(
            icon: Icons.replay_outlined,
            label: l10n.remedial,
            value: result.remedial,
          ),
          const SizedBox(height: 10),
          AppContainer(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(12),
            backgroundColor: colorScheme.surfaceContainer,
            elevation: 0,
            borderRadius: BorderRadius.circular(8),
            child: Text(
              result.keterangan.trim().isEmpty ? '-' : result.keterangan,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AverageBadge extends StatelessWidget {
  const _AverageBadge({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final color = academicResultScoreColor(context, value);

    return AppChipContainer(
      value:
          '${academicResultGrade(value)}  ${academicResultFormatScore(value)}/100',
      backgroundColor: color.withValues(alpha: 0.12),
      foregroundColor: color,
    );
  }
}

class _SimpleMetric extends StatelessWidget {
  const _SimpleMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class AcademicResultMessage extends StatelessWidget {
  const AcademicResultMessage({
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

    return Padding(
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
    );
  }
}
