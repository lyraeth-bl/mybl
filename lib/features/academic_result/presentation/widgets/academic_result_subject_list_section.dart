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
    this.isLoading = false,
  });

  final List<AcademicResultSubjectView> subjects;
  final String emptyMessage;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: l10n.subjectList,
      titleStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      action:
          AppChipContainer.outlined(
            child: Text(l10n.subjectCount(subjects.length)),
          ).toShimmer(
            context,
            isLoading: isLoading,
            width: 120,
            height: 24,
            borderRadius: .circular(24),
          ),
      sliver: subjects.isEmpty && !isLoading
          ? SliverToBoxAdapter(
              child: AppFramedContainer(
                margin: .zero,
                gap: .zero,
                elevation: 0,
                child: AppNoData(
                  icon: Icons.menu_book_outlined,
                  title: l10n.academicResultSubjectsEmptyTitle,
                  message: emptyMessage,
                ),
              ),
            )
          : SliverList.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                return _SubjectCard(
                  subject: subjects[index],
                  isLoading: isLoading,
                ).makeAnimate(
                  duration: const Duration(milliseconds: 250),
                  delay: Duration(milliseconds: 100 * index),
                );
              },
            ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject, required this.isLoading});

  final AcademicResultSubjectView subject;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final scoreColor = academicResultScoreColor(context, subject.average);

    return AppFramedContainer(
      margin: .only(bottom: 16),
      gap: .zero,
      elevation: 0,
      onTap: isLoading ? null : () => _showSubjectDetailSheet(context, subject),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              _SubjectIcon(
                subjectName: subject.subjectName,
                isLoading: isLoading,
              ),
              16.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      subject.subjectName,
                      maxLines: 3,
                      overflow: .ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ).toShimmer(
                      context,
                      isLoading: isLoading,
                      width: 160,
                      height: 16,
                      borderRadius: .circular(24),
                    ),
                    if ((subject.teacherName ?? '').trim().isNotEmpty) ...[
                      4.h,
                      Text(
                        subject.teacherName!,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ).toShimmer(
                        context,
                        isLoading: isLoading,
                        width: 120,
                        height: 16,
                        borderRadius: .circular(24),
                      ),
                    ],
                    16.h,
                    Text(
                      l10n.assessmentDataCount(subject.totalData),
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ).toShimmer(
                      context,
                      isLoading: isLoading,
                      width: 120,
                      height: 16,
                      borderRadius: .circular(24),
                    ),
                  ],
                ),
              ),
              16.w,
              Column(
                crossAxisAlignment: .end,
                children: [
                  Text(
                    academicResultGradeLabel(subject.average),
                    style: textTheme.titleLarge?.copyWith(color: scoreColor),
                  ).toShimmer(
                    context,
                    isLoading: isLoading,
                    width: 24,
                    height: 24,
                    borderRadius: .circular(8),
                  ),
                  4.h,
                  AppChipContainer(
                    backgroundColor: scoreColor.withValues(alpha: 0.12),
                    foregroundColor: scoreColor,
                    textStyle: textTheme.labelSmall,
                    child: Text(
                      '${academicResultFormatScore(subject.average)}/100',
                    ),
                  ).toShimmer(
                    context,
                    isLoading: isLoading,
                    width: 64,
                    height: 24,
                    borderRadius: .circular(24),
                  ),
                ],
              ),
            ],
          ),
          16.h,
          AppContainer(
            margin: .zero,
            backgroundColor: colorScheme.surfaceContainer,
            elevation: 0,
            borderRadius: .circular(8),
            child: Text(
              '"${subject.latestDescription}"',
              maxLines: 3,
              overflow: .ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: .italic,
                height: 1.35,
              ),
            ),
          ).toShimmer(
            context,
            isLoading: isLoading,
            width: double.infinity,
            height: 40,
            borderRadius: .circular(8),
          ),
        ],
      ),
    );
  }
}

class _SubjectIcon extends StatelessWidget {
  const _SubjectIcon({required this.subjectName, required this.isLoading});

  final String subjectName;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppIconContainer(
      icon: SubjectIconResolver.resolve(subjectName),
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
    ).toShimmer(
      context,
      isLoading: isLoading,
      width: 40,
      height: 40,
      borderRadius: .circular(24),
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: const .fromLTRB(24, 0, 24, 24),
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: AppContainer(
                    margin: .zero,
                    backgroundColor: colorScheme.surfaceContainerLow,
                    elevation: 0,
                    child: Row(
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                subject.subjectName,
                                style: textTheme.titleLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              if ((subject.teacherName ?? '')
                                  .trim()
                                  .isNotEmpty) ...[
                                8.h,
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
                        16.w,
                        _AverageBadge(value: subject.average),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: 16.h),
                SliverToBoxAdapter(
                  child: AppContainer(
                    margin: .zero,
                    backgroundColor: colorScheme.surfaceContainerLow,
                    elevation: 0,
                    child: Row(
                      children: [
                        Expanded(
                          child: _SimpleMetric(
                            label: l10n.average,
                            value: academicResultFormatScore(subject.average),
                          ),
                        ),
                        Expanded(
                          child: _SimpleMetric(
                            label: l10n.totalAssessment,
                            value: '${subject.totalData}',
                          ),
                        ),
                      ].separatedBy(16.w),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: 16.h),
                if (subject.results.isEmpty)
                  SliverToBoxAdapter(
                    child: AcademicResultMessage(
                      icon: Icons.fact_check_outlined,
                      message: l10n.noData,
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: subject.results.length,
                    itemBuilder: (context, index) {
                      final isLast = index == subject.results.length - 1;

                      return Padding(
                        padding: .only(bottom: isLast ? 0 : 16),
                        child: _ResultDetailCard(result: subject.results[index])
                            .makeAnimate(
                              duration: const Duration(milliseconds: 250),
                              delay: Duration(milliseconds: 100 * index),
                            ),
                      );
                    },
                  ),
              ],
            ),
          ),
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).toString();

    return AppContainer(
      margin: const .only(bottom: 8),
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Text(
                  result.aspekNilai,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              AppChipContainer(
                value: '${result.nilai}/100',
                backgroundColor: academicResultScoreColor(
                  context,
                  result.nilai.toDouble(),
                ).withValues(alpha: 0.12),
                foregroundColor: academicResultScoreColor(
                  context,
                  result.nilai.toDouble(),
                ),
              ),
            ].separatedBy(16.w),
          ),
          16.h,
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
          16.h,
          AppContainer(
            margin: .zero,
            backgroundColor: colorScheme.surfaceContainerHigh,
            elevation: 0,
            borderRadius: .circular(8),
            child: Text(
              result.keterangan.trim().isEmpty ? '-' : result.keterangan,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Padding(
      padding: const .only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
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
                fontWeight: .bold,
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
    final scoreColor = academicResultScoreColor(context, value);

    return AppChipContainer(
      value:
          '${academicResultGradeLabel(value)}  ${academicResultFormatScore(value)}/100',
      backgroundColor: scoreColor.withValues(alpha: 0.12),
      foregroundColor: scoreColor,
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
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: .ellipsis,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: .ellipsis,
          style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
        ),
      ].separatedBy(8.h),
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Padding(
      padding: const .symmetric(horizontal: 16, vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colorScheme.onSurfaceVariant),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ].separatedBy(16.h),
      ),
    );
  }
}
