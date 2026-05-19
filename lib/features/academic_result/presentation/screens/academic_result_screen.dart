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

class _AcademicResultContent extends StatefulWidget {
  const _AcademicResultContent({required this.academicResult});

  final AcademicResultResponse academicResult;

  @override
  State<_AcademicResultContent> createState() => _AcademicResultContentState();
}

class _AcademicResultContentState extends State<_AcademicResultContent> {
  int _selectedSubjectIndex = 0;

  @override
  void didUpdateWidget(covariant _AcademicResultContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final categoryCount = widget.academicResult.data.categories.length;
    if (categoryCount == 0) {
      _selectedSubjectIndex = 0;
    } else if (_selectedSubjectIndex >= categoryCount) {
      _selectedSubjectIndex = categoryCount - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.academicResult.data.categories;

    final children = [
      const SizedBox(height: 24),
      _AcademicResultMetaCard(academicResult: widget.academicResult),
      _OverallSummaryCard(
        summary: widget.academicResult.data.overallSummaryResult,
      ),
      if (categories.isEmpty)
        const _AcademicResultEmptyState()
      else ...[
        _SubjectFilter(
          categories: categories,
          selectedIndex: _selectedSubjectIndex,
          onSelected: (index) => setState(() => _selectedSubjectIndex = index),
        ),
        _SubjectResultCard(category: categories[_selectedSubjectIndex]),
      ],
      const SizedBox(height: 24),
    ].makeListAnimate();

    return SliverList.list(children: children);
  }
}

class _AcademicResultMetaCard extends StatelessWidget {
  const _AcademicResultMetaCard({required this.academicResult});

  final AcademicResultResponse academicResult;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              children: [
                Icon(Icons.school_outlined, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${l10n.semester} ${academicResult.meta.semester}',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ResponsiveDetailGrid(
              children: [
                _DetailTile(
                  icon: Icons.calendar_month_outlined,
                  label: l10n.schoolYear,
                  value: academicResult.meta.schoolSession,
                ),
                _DetailTile(
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

class _OverallSummaryCard extends StatelessWidget {
  const _OverallSummaryCard({required this.summary});

  final AcademicResultOverallSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.filled(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.primaryContainer,
      shape: const RoundedRectangleBorder(borderRadius: customRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.average,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDecimal(summary.average),
              style: textTheme.displaySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ResponsiveDetailGrid(
              children: [
                _DetailTile(
                  icon: Icons.functions_rounded,
                  label: l10n.sumativeAverage,
                  value: _formatDecimal(summary.sumatifAverage),
                  tinted: true,
                ),
                _DetailTile(
                  icon: Icons.assignment_outlined,
                  label: l10n.reportAverage,
                  value: _formatDecimal(summary.raportAverage),
                  tinted: true,
                ),
                _DetailTile(
                  icon: Icons.summarize_outlined,
                  label: l10n.semesterReportAverage,
                  value: _formatDecimal(summary.raportSemesterAverage),
                  tinted: true,
                ),
                _DetailTile(
                  icon: Icons.format_list_numbered_rounded,
                  label: l10n.totalAssessment,
                  value: '${summary.totalData}',
                  tinted: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectFilter extends StatelessWidget {
  const _SubjectFilter({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AcademicResultCategories> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.subject,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (var index = 0; index < categories.length; index++) ...[
                  ChoiceChip(
                    label: Text(categories[index].subjectName),
                    selected: selectedIndex == index,
                    onSelected: (_) => onSelected(index),
                    showCheckmark: false,
                  ),
                  if (index != categories.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectResultCard extends StatelessWidget {
  const _SubjectResultCard({required this.category});

  final AcademicResultCategories category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final teacherName = category.subjectTeacherName;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.subjectName,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (teacherName != null && teacherName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.teacher}: $teacherName',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _SummaryBadge(summary: category.summary),
              ],
            ),
            const SizedBox(height: 16),
            _ResponsiveDetailGrid(
              children: [
                _DetailTile(
                  icon: Icons.analytics_outlined,
                  label: l10n.average,
                  value: _formatDecimal(category.summary.average),
                ),
                _DetailTile(
                  icon: Icons.format_list_numbered_rounded,
                  label: l10n.totalAssessment,
                  value: '${category.summary.totalData}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (category.listResult.isEmpty)
              const _AcademicResultEmptyState()
            else
              ...category.listResult.map(
                (result) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ResultDetailPanel(result: result),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({required this.summary});

  final AcademicResultSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: colorScheme.secondaryContainer,
        shape: const RoundedRectangleBorder(borderRadius: customRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.average,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          Text(
            _formatDecimal(summary.average),
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          _ResponsiveDetailGrid(
            children: [
              _DetailTile(
                icon: Icons.tag_outlined,
                label: l10n.id,
                value: '${result.id}',
              ),
              _DetailTile(
                icon: Icons.badge_outlined,
                label: l10n.nis,
                value: result.nis,
              ),
              _DetailTile(
                icon: Icons.school_outlined,
                label: l10n.classRoom,
                value: result.kelas,
              ),
              _DetailTile(
                icon: Icons.meeting_room_outlined,
                label: l10n.classNumber,
                value: result.nomorKelas,
              ),
              _DetailTile(
                icon: Icons.looks_one_outlined,
                label: l10n.scoreSequence,
                value: '${result.nilaiKe}',
              ),
              _DetailTile(
                icon: Icons.event_outlined,
                label: l10n.date,
                value: DateFormat.yMMMd(locale).format(result.tanggal),
              ),
              _DetailTile(
                icon: Icons.fact_check_outlined,
                label: l10n.assessmentAspect,
                value: result.aspekNilai,
              ),
              _DetailTile(
                icon: Icons.replay_outlined,
                label: l10n.remedial,
                value: result.remedial,
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
                icon: Icons.description_outlined,
                label: l10n.description,
                value: result.keterangan,
              ),
              _DetailTile(
                icon: Icons.category_outlined,
                label: l10n.scoreType,
                value: result.jenisNilai,
              ),
              _DetailTile(
                icon: Icons.apartment_outlined,
                label: l10n.unit,
                value: result.unit,
              ),
            ],
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
    this.tinted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final backgroundColor = tinted
        ? colorScheme.primary.withValues(alpha: 0.12)
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = tinted
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    color: foregroundColor,
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
