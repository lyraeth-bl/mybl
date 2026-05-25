// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../core/widgets/titled_content_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/academic_result/academic_result.dart';
import '../bloc/academic_result_bloc.dart';

class AcademicResultScreen extends StatelessWidget {
  const AcademicResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AcademicResultBloc>(
      create: (context) => di<AcademicResultBloc>(),
      child: const _AcademicResultView(),
    );
  }
}

class _AcademicResultView extends StatefulWidget {
  const _AcademicResultView();

  @override
  State<_AcademicResultView> createState() => _AcademicResultViewState();
}

class _AcademicResultViewState extends State<_AcademicResultView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicResultBloc>().add(
        const AcademicResultEvent.fetchAcademicResult(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: RefreshWrapper(
        onRefresh: () =>
            blocRefresh<
              AcademicResultBloc,
              AcademicResultEvent,
              AcademicResultState
            >(
              context: context,
              event: const AcademicResultEvent.fetchAcademicResult(),
              isDone: (state) => state.maybeWhen(
                success: (_) => true,
                failure: (_) => true,
                orElse: () => false,
              ),
            ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            const _AcademicResultHeader(),
            BlocBuilder<AcademicResultBloc, AcademicResultState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loading: () => const _AcademicResultLoadingList(),
                  success: (academicResult) =>
                      _AcademicResultContent(academicResult: academicResult),
                  failure: (failure) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: _AcademicResultFailure(
                      message: failure.localizedMessage(
                        AppLocalizations.of(context)!,
                      ),
                    ),
                  ),
                  orElse: () => const _AcademicResultLoadingList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademicResultHeader extends StatelessWidget {
  const _AcademicResultHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar.medium(
      title: Text(
        l10n.academicResult,
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: colorScheme.primaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      centerTitle: true,
      floating: false,
      pinned: true,
    );
  }
}

class _AcademicResultContent extends StatelessWidget {
  const _AcademicResultContent({required this.academicResult});

  final AcademicResultResponse academicResult;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = academicResult.data.categories;

    final children = [
      const SizedBox(height: 24),
      _AcademicResultOverviewSection(academicResult: academicResult),
      _OverallSummarySection(summary: academicResult.data.overallSummaryResult),
      if (categories.isEmpty)
        const _AcademicResultEmptyState()
      else
        TitledContentContainer(
          title: l10n.subject,
          contentPadding: const EdgeInsets.all(12),
          child: _SubjectList(categories: categories),
        ),
      const SizedBox(height: 24),
    ].makeListAnimate();

    return SliverList.list(children: children);
  }
}

class _AcademicResultOverviewSection extends StatelessWidget {
  const _AcademicResultOverviewSection({required this.academicResult});

  final AcademicResultResponse academicResult;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TitledContentContainer(
      title: '${l10n.semester} ${academicResult.meta.semester}',
      titleIcon: const Icon(Icons.school_outlined),
      contentPadding: const EdgeInsets.all(12),
      child: _CompactInfoGrid(
        children: [
          _MetricTile(
            icon: Icons.calendar_month_outlined,
            label: l10n.schoolYear,
            value: academicResult.meta.schoolSession,
          ),
          _MetricTile(
            icon: Icons.category_outlined,
            label: l10n.subject,
            value: '${academicResult.data.categories.length}',
          ),
        ],
      ),
    );
  }
}

class _OverallSummarySection extends StatelessWidget {
  const _OverallSummarySection({required this.summary});

  final AcademicResultOverallSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TitledContentContainer(
      title: l10n.average,
      titleIcon: const Icon(Icons.analytics_outlined),
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDecimal(summary.average),
            style: textTheme.displaySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _CompactInfoGrid(
            children: [
              _MetricTile(
                icon: Icons.functions_rounded,
                label: l10n.sumativeAverage,
                value: _formatDecimal(summary.sumatifAverage),
              ),
              _MetricTile(
                icon: Icons.assignment_outlined,
                label: l10n.reportAverage,
                value: _formatDecimal(summary.raportAverage),
              ),
              _MetricTile(
                icon: Icons.summarize_outlined,
                label: l10n.semesterReportAverage,
                value: _formatDecimal(summary.raportSemesterAverage),
              ),
              _MetricTile(
                icon: Icons.format_list_numbered_rounded,
                label: l10n.totalAssessment,
                value: '${summary.totalData}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectList extends StatelessWidget {
  const _SubjectList({required this.categories});

  final List<AcademicResultCategories> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < categories.length; index++) ...[
          _SubjectTile(category: categories[index]),
          if (index != categories.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.category});

  final AcademicResultCategories category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final teacherName = category.subjectTeacherName;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: customRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showSubjectDetailSheet(context, category),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: colorScheme.secondaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: customRadius,
                      ),
                    ),
                    child: Text(
                      _formatDecimal(category.summary.average),
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.subjectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (teacherName != null && teacherName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            teacherName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${category.summary.totalData} ${l10n.totalAssessment.toLowerCase()}',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showSubjectDetailSheet(
  BuildContext context,
  AcademicResultCategories category,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.38,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return _SubjectDetailSheet(
            category: category,
            scrollController: scrollController,
          );
        },
      );
    },
  );
}

class _SubjectDetailSheet extends StatelessWidget {
  const _SubjectDetailSheet({
    required this.category,
    required this.scrollController,
  });

  final AcademicResultCategories category;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final teacherName = category.subjectTeacherName;

    return SafeArea(
      top: false,
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.subjectName,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (teacherName != null && teacherName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.teacher}: $teacherName',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _AverageBadge(value: category.summary.average),
            ],
          ),
          const SizedBox(height: 18),
          _CompactInfoGrid(
            children: [
              _MetricTile(
                icon: Icons.analytics_outlined,
                label: l10n.average,
                value: _formatDecimal(category.summary.average),
              ),
              _MetricTile(
                icon: Icons.format_list_numbered_rounded,
                label: l10n.totalAssessment,
                value: '${category.summary.totalData}',
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (category.listResult.isEmpty)
            const _AcademicResultEmptyState()
          else
            for (final result in category.listResult) ...[
              _ResultDetailPanel(result: result),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _CompactInfoGrid extends StatelessWidget {
  const _CompactInfoGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 520 ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: crossAxisCount == 4 ? 2.2 : 2.35,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: children,
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: const RoundedRectangleBorder(borderRadius: customRadius),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultDetailPanel extends StatelessWidget {
  const _ResultDetailPanel({required this.result});

  final AcademicResultEntity result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final classLabel = '${result.kelas} ${result.nomorKelas}'.trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainer,
        shape: const RoundedRectangleBorder(borderRadius: customRadius),
      ),
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
              _ScoreBadge(score: result.nilai),
            ],
          ),
          const SizedBox(height: 12),
          _AssessmentMetaPanel(
            result: result,
            formattedDate: DateFormat.yMMMd(locale).format(result.tanggal),
          ),
          const SizedBox(height: 12),
          _ResponsiveDetailGrid(
            children: [
              _DetailTile(
                icon: Icons.school_outlined,
                label: l10n.classRoom,
                value: classLabel,
              ),
              _DetailTile(
                icon: Icons.calendar_month_outlined,
                label: l10n.schoolYear,
                value: result.tajaran,
              ),
              _DetailTile(
                icon: Icons.event_note_outlined,
                label: l10n.semester,
                value: result.semester,
              ),
              _DetailTile(
                icon: Icons.category_outlined,
                label: l10n.scoreType,
                value: result.jenisNilai,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DescriptionPanel(description: result.keterangan),
        ],
      ),
    );
  }
}

class _AssessmentMetaPanel extends StatelessWidget {
  const _AssessmentMetaPanel({
    required this.result,
    required this.formattedDate,
  });

  final AcademicResultEntity result;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _LargeDetailPanel(
      icon: Icons.fact_check_outlined,
      title: l10n.assessmentAspect,
      children: [
        _InlineDetail(label: l10n.scoreSequence, value: '${result.nilaiKe}'),
        _InlineDetail(label: l10n.date, value: formattedDate),
        _InlineDetail(label: l10n.assessmentAspect, value: result.aspekNilai),
        _InlineDetail(label: l10n.remedial, value: result.remedial),
      ],
    );
  }
}

class _DescriptionPanel extends StatelessWidget {
  const _DescriptionPanel({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _LargeDetailPanel(
      icon: Icons.description_outlined,
      title: l10n.description,
      children: [Text(description.isEmpty ? '-' : description)],
    );
  }
}

class _LargeDetailPanel extends StatelessWidget {
  const _LargeDetailPanel({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: const RoundedRectangleBorder(borderRadius: customRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DefaultTextStyle.merge(
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineDetail extends StatelessWidget {
  const _InlineDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
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

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: colorScheme.primaryContainer,
        shape: const RoundedRectangleBorder(borderRadius: customRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.score,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            '$score',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: colorScheme.primaryContainer,
        shape: const RoundedRectangleBorder(borderRadius: customRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.average,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            _formatDecimal(value),
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveDetailGrid extends StatelessWidget {
  const _ResponsiveDetailGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 520 ? 3 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: crossAxisCount == 3 ? 2.7 : 2.35,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: children,
        );
      },
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: const RoundedRectangleBorder(borderRadius: customRadius),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AcademicResultLoadingList extends StatelessWidget {
  const _AcademicResultLoadingList();

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: const [
        SizedBox(height: 16),
        _LoadingCard(),
        _LoadingCard(),
        _LoadingCard(),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.filled(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: customRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: const SizedBox().toShimmer(
                    context,
                    width: double.infinity,
                    height: 24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                const SizedBox().toShimmer(
                  context,
                  width: 64,
                  height: 48,
                  borderRadius: customRadius,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _LoadingGrid(count: 4),
          ],
        ),
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: List.generate(
        count,
        (_) => const SizedBox().toShimmer(
          context,
          width: double.infinity,
          height: double.infinity,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _AcademicResultEmptyState extends StatelessWidget {
  const _AcademicResultEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noData,
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

class _AcademicResultFailure extends StatelessWidget {
  const _AcademicResultFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.read<AcademicResultBloc>().add(
                const AcademicResultEvent.fetchAcademicResult(),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                l10n.tryAgain,
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDecimal(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);

  return value.toStringAsFixed(1);
}
