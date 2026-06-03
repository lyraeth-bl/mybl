// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
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
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: const _AcademicResultAppBar(),
      body: const _AcademicResultBody(),
    );
  }
}

class _AcademicResultAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _AcademicResultAppBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: colorScheme.primaryContainer,
      surfaceTintColor: colorScheme.primaryContainer,
      toolbarHeight: 72,
      title: Text(
        l10n.academicResult,
        style: const TextStyle(fontWeight: .bold, letterSpacing: 2),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class _AcademicResultBody extends StatelessWidget {
  const _AcademicResultBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: RefreshWrapper(
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
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
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
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
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

    return SliverMainAxisGroup(
      slivers: [
        _AcademicResultOverviewSection(academicResult: academicResult),
        _OverallSummarySection(
          summary: academicResult.data.overallSummaryResult,
        ),
        if (categories.isEmpty)
          const SliverToBoxAdapter(child: _AcademicResultEmptyState())
        else
          AppSliverGroup(
            title: l10n.subject,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            sliver: _SubjectList(categories: categories),
          ),
      ],
    );
  }
}

class _AcademicResultOverviewSection extends StatelessWidget {
  const _AcademicResultOverviewSection({required this.academicResult});

  final AcademicResultResponse academicResult;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSliverGroup(
      title: '${l10n.semester} ${academicResult.meta.semester}',
      titleStyle: textTheme.titleMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AppContainer(
        margin: EdgeInsets.zero,
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.surfaceContainerHighest,
            offset: const Offset(5, 5),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLead(
              icon: Icons.school_outlined,
              title: '${l10n.semester} ${academicResult.meta.semester}',
              subtitle: academicResult.meta.schoolSession,
            ),
            const SizedBox(height: 16),
            _CompactInfoGrid(
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
          ],
        ),
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

    return AppSliverGroup(
      title: l10n.average,
      titleStyle: textTheme.titleMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AppContainer(
        margin: EdgeInsets.zero,
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.surfaceContainerHighest,
            offset: const Offset(5, 5),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.average,
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDecimal(summary.average),
                        style: textTheme.displaySmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
      ),
    );
  }
}

class _SectionLead extends StatelessWidget {
  const _SectionLead({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle.isEmpty ? '-' : subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubjectList extends StatelessWidget {
  const _SubjectList({required this.categories});

  final List<AcademicResultCategories> categories;

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: categories
          .asMap()
          .entries
          .map(
            (entry) => _SubjectTile(
              category: entry.value,
              shape: _subjectTileShape(entry.key, categories.length - 1),
            ),
          )
          .toList()
          .makeListAnimate(),
    );
  }

  ShapeBorder _subjectTileShape(int index, int lastIndex) {
    if (lastIndex == 0) {
      return RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
    }

    return index.makeVerticalGoogleShape(lastIndex);
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.category, required this.shape});

  final AcademicResultCategories category;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final teacherName = category.subjectTeacherName;

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: shape,
      borderRadius: null,
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colorScheme.surfaceContainerHighest,
          offset: const Offset(5, 5),
        ),
      ],
      padding: EdgeInsets.zero,
      onTap: () => _showSubjectDetailSheet(context, category),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
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
                  Row(
                    children: [
                      Icon(
                        Icons.format_list_numbered_rounded,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${category.summary.totalData} ${l10n.totalAssessment.toLowerCase()}',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
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
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: _SubjectDetailSheetContent(
                category: category,
                scrollController: scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectDetailSheetContent extends StatelessWidget {
  const _SubjectDetailSheetContent({
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

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        AppContainer(
          margin: EdgeInsets.zero,
          backgroundColor: colorScheme.surfaceContainerLow,
          elevation: 0,
          child: Row(
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
        ),
        const SizedBox(height: 12),
        AppContainer(
          margin: EdgeInsets.zero,
          backgroundColor: colorScheme.surfaceContainerLow,
          elevation: 0,
          child: _CompactInfoGrid(
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
        ),
        const SizedBox(height: 12),
        if (category.listResult.isEmpty)
          const _AcademicResultEmptyState()
        else
          ...category.listResult
              .asMap()
              .entries
              .map(
                (entry) => _ResultDetailPanel(
                  result: entry.value,
                  shape: _resultDetailShape(
                    entry.key,
                    category.listResult.length - 1,
                  ),
                ),
              )
              .toList()
              .makeListAnimate(),
      ],
    );
  }

  ShapeBorder _resultDetailShape(int index, int lastIndex) {
    if (lastIndex == 0) {
      return RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
    }

    return index.makeVerticalGoogleShape(lastIndex);
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
        color: colorScheme.surfaceContainer,
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
  const _ResultDetailPanel({required this.result, required this.shape});

  final AcademicResultEntity result;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final classLabel = '${result.kelas} ${result.nomorKelas}'.trim();

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: shape,
      borderRadius: null,
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 14),
          _AssessmentMetaPanel(
            result: result,
            formattedDate: DateFormat.yMMMd(locale).format(result.tanggal),
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 14),
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
        color: colorScheme.surfaceContainer,
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
        color: colorScheme.surfaceContainer,
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
    return SliverMainAxisGroup(
      slivers: [
        const _LoadingOverviewSection(),
        const _LoadingSummarySection(),
        const _LoadingHeader(width: 96),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList.list(
            children: List.generate(
              4,
              (index) =>
                  _LoadingSubjectTile(shape: index.makeVerticalGoogleShape(3)),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingOverviewSection extends StatelessWidget {
  const _LoadingOverviewSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverMainAxisGroup(
      slivers: [
        const _LoadingHeader(width: 112),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: AppContainer(
              margin: EdgeInsets.zero,
              backgroundColor: colorScheme.surfaceContainerLow,
              elevation: 0,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colorScheme.surfaceContainerHighest,
                  offset: const Offset(5, 5),
                ),
              ],
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LoadingSectionLead(),
                  SizedBox(height: 16),
                  _LoadingGrid(count: 2),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingSummarySection extends StatelessWidget {
  const _LoadingSummarySection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverMainAxisGroup(
      slivers: [
        const _LoadingHeader(width: 88),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: AppContainer(
              margin: EdgeInsets.zero,
              backgroundColor: colorScheme.surfaceContainerLow,
              elevation: 0,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colorScheme.surfaceContainerHighest,
                  offset: const Offset(5, 5),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('').toShimmer(
                        context,
                        width: 56,
                        height: 56,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '',
                          ).toShimmer(context, width: 72, height: 12),
                          const SizedBox(height: 8),
                          const Text(
                            '',
                          ).toShimmer(context, width: 96, height: 32),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _LoadingGrid(count: 4),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingHeader extends StatelessWidget {
  const _LoadingHeader({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 28, 16, 8),
        child: const Text('').toShimmer(context, width: width, height: 14),
      ),
    );
  }
}

class _LoadingSectionLead extends StatelessWidget {
  const _LoadingSectionLead();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('').toShimmer(
          context,
          width: 48,
          height: 48,
          borderRadius: BorderRadius.circular(18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('').toShimmer(context, width: 132, height: 16),
              const SizedBox(height: 8),
              const Text('').toShimmer(context, width: 180, height: 14),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingSubjectTile extends StatelessWidget {
  const _LoadingSubjectTile({required this.shape});

  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: shape,
      borderRadius: null,
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colorScheme.surfaceContainerHighest,
          offset: const Offset(5, 5),
        ),
      ],
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Text('').toShimmer(
            context,
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('').toShimmer(context, width: 160, height: 14),
                const SizedBox(height: 8),
                const Text('').toShimmer(context, width: 120, height: 12),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('').toShimmer(
                      context,
                      width: 14,
                      height: 14,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    const SizedBox(width: 6),
                    const Text('').toShimmer(context, width: 104, height: 11),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('').toShimmer(
            context,
            width: 24,
            height: 24,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}

class _LoadingMetricTile extends StatelessWidget {
  const _LoadingMetricTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainer,
        shape: const RoundedRectangleBorder(borderRadius: customRadius),
      ),
      child: Row(
        children: [
          const Text('').toShimmer(
            context,
            width: 18,
            height: 18,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('').toShimmer(context, width: 64, height: 10),
                const SizedBox(height: 6),
                const Text('').toShimmer(context, width: 88, height: 13),
              ],
            ),
          ),
        ],
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
      children: List.generate(count, (_) => const _LoadingMetricTile()),
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
