// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../domain/entities/discipline.dart';
import '../bloc/demerit_bloc/demerit_bloc.dart';
import '../bloc/merit_bloc/merit_bloc.dart';

class MeritDemeritScreen extends StatelessWidget {
  const MeritDemeritScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MeritBloc>(create: (context) => di<MeritBloc>()),
        BlocProvider<DemeritBloc>(create: (context) => di<DemeritBloc>()),
      ],
      child: const _MeritDemeritView(),
    );
  }
}

class _MeritDemeritView extends StatefulWidget {
  const _MeritDemeritView();

  @override
  State<_MeritDemeritView> createState() => _MeritDemeritViewState();
}

class _MeritDemeritViewState extends State<_MeritDemeritView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeritBloc>().add(const MeritEvent.fetchMerit());
      context.read<DemeritBloc>().add(const DemeritEvent.fetchDemerit());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _MeritDemeritAppBar(),
      body: _MeritDemeritBody(),
    );
  }
}

@immutable
class _MeritDemeritAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _MeritDemeritAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(
      toolbarHeight: 72,
      title: Text(l10n.meritAndDemerit),
      centerTitle: true,
      actions: const <Widget>[_MeritDemeritProfileAction()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _MeritDemeritProfileAction extends StatelessWidget {
  const _MeritDemeritProfileAction();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<
      UserBloc,
      UserState,
      ({String? imageUrl, String? name})
    >(
      selector: (state) => state.maybeWhen(
        success: (student) => (
          imageUrl: student.profileImageUrl,
          name: student.nama ?? student.namaPanggilan,
        ),
        orElse: () => (imageUrl: null, name: null),
      ),
      builder: (context, profile) {
        return Tooltip(
          message: l10n.profile,
          child: InkResponse(
            onTap: () => context.go(RouteNames.profile),
            customBorder: const CircleBorder(),
            radius: 24,
            child: SizedBox.square(
              dimension: kMinInteractiveDimension,
              child: Center(
                child: AppProfilePicture(
                  imageUrl: profile.imageUrl,
                  initials: AppProfilePicture.initialFrom(profile.name),
                  radius: 20,
                  side: BorderSide(color: colorScheme.outlineVariant, width: 2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MeritDemeritBody extends StatefulWidget {
  const _MeritDemeritBody();

  @override
  State<_MeritDemeritBody> createState() => _MeritDemeritBodyState();
}

class _MeritDemeritBodyState extends State<_MeritDemeritBody> {
  String? _selectedSchoolSession;
  String? _selectedSemester;

  Future<void> _refresh() {
    final meritRefresh = blocRefresh<MeritBloc, MeritEvent, MeritState>(
      context: context,
      event: const MeritEvent.fetchMerit(forceRefresh: true),
      isDone: (state) => state.maybeWhen(
        success: (_) => true,
        emptyData: () => true,
        failure: (_) => true,
        orElse: () => false,
      ),
    );
    final demeritRefresh = blocRefresh<DemeritBloc, DemeritEvent, DemeritState>(
      context: context,
      event: const DemeritEvent.fetchDemerit(forceRefresh: true),
      isDone: (state) => state.maybeWhen(
        success: (_) => true,
        emptyData: () => true,
        failure: (_) => true,
        orElse: () => false,
      ),
    );

    return Future.wait([meritRefresh, demeritRefresh]).then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshWrapper(
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          BlocBuilder<MeritBloc, MeritState>(
            builder: (context, meritState) {
              return BlocBuilder<DemeritBloc, DemeritState>(
                builder: (context, demeritState) {
                  final isLoading =
                      meritState.maybeWhen(
                        loading: () => true,
                        initial: () => true,
                        orElse: () => false,
                      ) ||
                      demeritState.maybeWhen(
                        loading: () => true,
                        initial: () => true,
                        orElse: () => false,
                      );
                  final failure = meritState.maybeWhen(
                    failure: (failure) => failure,
                    orElse: () => demeritState.maybeWhen(
                      failure: (failure) => failure,
                      orElse: () => null,
                    ),
                  );

                  if (failure != null) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _DisciplineFailure(
                        message: failure.localizedMessage(l10n),
                        onRetry: () {
                          context.read<MeritBloc>().add(
                            const MeritEvent.fetchMerit(forceRefresh: true),
                          );
                          context.read<DemeritBloc>().add(
                            const DemeritEvent.fetchDemerit(forceRefresh: true),
                          );
                        },
                      ),
                    );
                  }

                  if (isLoading) {
                    return const _DisciplineLoadingContent();
                  }

                  final merits = meritState.maybeWhen(
                    success: (merits) => merits,
                    orElse: () => const <MeritEntity>[],
                  );
                  final demerits = demeritState.maybeWhen(
                    success: (demerits) => demerits,
                    orElse: () => const <DemeritEntity>[],
                  );
                  final items = [
                    ...merits.map(_DisciplineItem.fromMerit),
                    ...demerits.map(_DisciplineItem.fromDemerit),
                  ]..sort((a, b) => b.date.compareTo(a.date));
                  final filteredItems = _filterItems(items);

                  return _DisciplineContent(
                    items: items,
                    filteredItems: filteredItems,
                    selectedSchoolSession: _selectedSchoolSession,
                    selectedSemester: _selectedSemester,
                    onSchoolSessionChanged: (value) {
                      setState(() => _selectedSchoolSession = value);
                    },
                    onSemesterChanged: (value) {
                      setState(() => _selectedSemester = value);
                    },
                    emptyMessage: l10n.noDisciplineData,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  List<_DisciplineItem> _filterItems(List<_DisciplineItem> items) {
    return items.where((item) {
      final matchesSchoolSession =
          _selectedSchoolSession == null ||
          item.schoolSession == _selectedSchoolSession;
      final matchesSemester =
          _selectedSemester == null || item.semester == _selectedSemester;

      return matchesSchoolSession && matchesSemester;
    }).toList();
  }
}

class _DisciplineContent extends StatelessWidget {
  const _DisciplineContent({
    required this.items,
    required this.filteredItems,
    required this.selectedSchoolSession,
    required this.selectedSemester,
    required this.onSchoolSessionChanged,
    required this.onSemesterChanged,
    required this.emptyMessage,
  });

  final List<_DisciplineItem> items;
  final List<_DisciplineItem> filteredItems;
  final String? selectedSchoolSession;
  final String? selectedSemester;
  final ValueChanged<String?> onSchoolSessionChanged;
  final ValueChanged<String?> onSemesterChanged;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final meritPoint = filteredItems
        .where((item) => item.isMerit)
        .fold(0, (total, item) => total + item.point);
    final demeritPoint = filteredItems
        .where((item) => !item.isMerit)
        .fold(0, (total, item) => total + item.point);

    return SliverMainAxisGroup(
      slivers: [
        _DisciplineSummarySection(
          meritPoint: meritPoint,
          demeritPoint: demeritPoint,
        ),
        _DisciplineFilterGroup(
          schoolSessions: _schoolSessions(items),
          semesters: _semesters(items),
          selectedSchoolSession: selectedSchoolSession,
          selectedSemester: selectedSemester,
          onSchoolSessionChanged: onSchoolSessionChanged,
          onSemesterChanged: onSemesterChanged,
          activityCount: filteredItems.length,
          sliver: filteredItems.isEmpty
              ? SliverToBoxAdapter(
                  child: _DisciplineEmptyView(message: emptyMessage),
                )
              : SliverList.list(
                  children: filteredItems
                      .map((item) => _DisciplineActivityCard(item: item))
                      .toList()
                      .makeListAnimate(),
                ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  List<String> _schoolSessions(List<_DisciplineItem> items) {
    final schoolSessions = items
        .map((item) => item.schoolSession)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList();
    schoolSessions.sort((a, b) => b.compareTo(a));
    return schoolSessions;
  }

  List<String> _semesters(List<_DisciplineItem> items) {
    final semesters = items
        .map((item) => item.semester)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList();
    semesters.sort();
    return semesters;
  }
}

class _DisciplineSummarySection extends StatelessWidget {
  const _DisciplineSummarySection({
    required this.meritPoint,
    required this.demeritPoint,
  });

  final int meritPoint;
  final int demeritPoint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appColors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final disciplinePoint = (100 + meritPoint - demeritPoint)
        .clamp(0, 100)
        .toInt();
    final statusColor = _statusColor(
      colorScheme: colorScheme,
      appColors: appColors,
      point: disciplinePoint,
    );

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            AppContainer(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              borderRadius: BorderRadius.circular(16),
              elevation: 0,
              child: Column(
                children: [
                  Text(
                    l10n.point,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: .bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$disciplinePoint',
                        style: textTheme.displaySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: .bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          ' / 100',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer.withValues(
                              alpha: 0.8,
                            ),
                            fontWeight: .bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: disciplinePoint / 100,
                      color: statusColor,
                      backgroundColor: colorScheme.onPrimaryContainer
                          .withValues(alpha: 0.24),
                      // ignore: deprecated_member_use
                      year2023: false,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusText(l10n, disciplinePoint),
                    textAlign: TextAlign.center,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: .bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DisciplineStatCard(
                    label: l10n.merit,
                    point: meritPoint,
                    isMerit: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DisciplineStatCard(
                    label: l10n.demerit,
                    point: demeritPoint,
                    isMerit: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor({
    required ColorScheme colorScheme,
    required AppColors appColors,
    required int point,
  }) {
    if (point >= 80) return appColors.success;
    if (point >= 60) return appColors.warning;
    return colorScheme.error;
  }

  String _statusText(AppLocalizations l10n, int point) {
    if (point >= 100) return l10n.disciplineStatusExcellent;
    if (point >= 80) return l10n.disciplineStatusGood;
    if (point >= 60) return l10n.disciplineStatusNeedsAttention;
    return l10n.disciplineStatusCritical;
  }
}

class _DisciplineStatCard extends StatelessWidget {
  const _DisciplineStatCard({
    required this.label,
    required this.point,
    required this.isMerit,
  });

  final String label;
  final int point;
  final bool isMerit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appColors = AppColors.of(context);
    final foregroundColor = isMerit ? appColors.success : colorScheme.error;
    final backgroundColor = foregroundColor.withValues(alpha: 0.12);

    return AppContainer(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          AppIconContainer(
            icon: isMerit ? Icons.emoji_events_outlined : Icons.warning_rounded,
            padding: const EdgeInsets.all(8),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
          const SizedBox(height: 16),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: .bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${isMerit ? '+' : '-'}$point ${l10nPointLabel(context)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(
              color: foregroundColor,
              fontWeight: .bold,
            ),
          ),
        ],
      ),
    );
  }

  String l10nPointLabel(BuildContext context) =>
      AppLocalizations.of(context)!.point;
}

class _DisciplineFilterGroup extends StatelessWidget {
  const _DisciplineFilterGroup({
    required this.schoolSessions,
    required this.semesters,
    required this.selectedSchoolSession,
    required this.selectedSemester,
    required this.onSchoolSessionChanged,
    required this.onSemesterChanged,
    required this.activityCount,
    required this.sliver,
  });

  final List<String> schoolSessions;
  final List<String> semesters;
  final String? selectedSchoolSession;
  final String? selectedSemester;
  final ValueChanged<String?> onSchoolSessionChanged;
  final ValueChanged<String?> onSemesterChanged;
  final int activityCount;
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: '',
      pinned: true,
      headerHeight: 72,
      headerPadding: EdgeInsets.zero,
      backgroundColor: colorScheme.surface,
      titleOffset: 0,
      collapsedOpacity: 1,
      action: SizedBox(
        width: MediaQuery.sizeOf(context).width - 8,
        height: 72,
        child: Row(
          children: [
            Expanded(
              child: _FilterChipButton(
                label: selectedSchoolSession ?? l10n.allSchoolYears,
                onTap: () => _showFilterSheet(
                  context: context,
                  title: l10n.schoolYear,
                  allLabel: l10n.allSchoolYears,
                  values: schoolSessions,
                  selectedValue: selectedSchoolSession,
                  onChanged: onSchoolSessionChanged,
                ),
                margin: EdgeInsets.only(left: 8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _FilterChipButton(
                label: selectedSemester ?? l10n.allSemesters,
                onTap: () => _showFilterSheet(
                  context: context,
                  title: l10n.semester,
                  allLabel: l10n.allSemesters,
                  values: semesters,
                  selectedValue: selectedSemester,
                  onChanged: onSemesterChanged,
                ),
                margin: EdgeInsets.only(right: 16),
              ),
            ),
          ],
        ),
      ),
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        sliver: AppSliverGroup(
          title: l10n.disciplineActivityLog,
          headerHeight: 52,
          headerPadding: const EdgeInsetsDirectional.only(top: 8, bottom: 8),
          titleOffset: 0,
          collapsedOpacity: 1,
          action: AppChipContainer(
            value: l10n.dataCount(activityCount),
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
          sliver: sliver,
        ),
      ),
    );
  }

  Future<void> _showFilterSheet({
    required BuildContext context,
    required String title,
    required String allLabel,
    required List<String> values,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => _FilterSheet(
        title: title,
        allLabel: allLabel,
        values: values,
        selectedValue: selectedValue,
      ),
    );

    if (selected == null) return;
    onChanged(selected == _FilterSheet.allValue ? null : selected);
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.onTap,
    required this.margin,
  });

  final String label;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return AppChipContainer(
      onTap: onTap,
      margin: margin,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more_rounded, size: 18),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.title,
    required this.allLabel,
    required this.values,
    required this.selectedValue,
  });

  static const String allValue = '__all__';

  final String title;
  final String allLabel;
  final List<String> values;
  final String? selectedValue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                selectedValue == null
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(allLabel),
              onTap: () => Navigator.of(context).pop(allValue),
            ),
            ...values.map(
              (value) => ListTile(
                leading: Icon(
                  selectedValue == value
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(value),
                onTap: () => Navigator.of(context).pop(value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisciplineActivityCard extends StatelessWidget {
  const _DisciplineActivityCard({required this.item});

  final _DisciplineItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final appColors = AppColors.of(context);
    final foregroundColor = item.isMerit
        ? appColors.success
        : colorScheme.error;
    final backgroundColor = foregroundColor.withValues(alpha: 0.12);
    final formatter = DateFormat(
      'd MMM yyyy',
      Localizations.localeOf(context).toString(),
    );

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 4),
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconContainer(
            icon: item.isMerit
                ? Icons.emoji_events_outlined
                : Icons.schedule_rounded,
            padding: const EdgeInsets.all(8),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: .bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.teacher}: ${item.teacherName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: .bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.format(item.date.toLocal()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${item.isMerit ? '+' : '-'}${item.point}',
            style: textTheme.titleSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DisciplineLoadingContent extends StatelessWidget {
  const _DisciplineLoadingContent();

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(child: _SummaryLoading()),
        ),
        AppSliverGroup(
          title: '',
          pinned: true,
          headerHeight: 72,
          headerPadding: EdgeInsets.zero,
          backgroundColor: Theme.of(context).colorScheme.surface,
          titleOffset: 0,
          collapsedOpacity: 1,
          action: SizedBox(
            width: MediaQuery.sizeOf(context).width - 8,
            height: 72,
            child: const Row(
              children: [
                Expanded(child: _FilterLoadingChip()),
                SizedBox(width: 8),
                Expanded(child: _FilterLoadingChip()),
              ],
            ),
          ),
          sliver: SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList.list(
              children: const [
                _ActivityLoadingCard(),
                _ActivityLoadingCard(),
                _ActivityLoadingCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryLoading extends StatelessWidget {
  const _SummaryLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _LoadingBox(height: 138),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(child: _LoadingBox(height: 112)),
            SizedBox(width: 12),
            Expanded(child: _LoadingBox(height: 112)),
          ],
        ),
      ],
    );
  }
}

class _FilterLoadingChip extends StatelessWidget {
  const _FilterLoadingChip();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.fromSTEB(8, 12, 0, 12),
      child: _LoadingBox(height: 44),
    );
  }
}

class _ActivityLoadingCard extends StatelessWidget {
  const _ActivityLoadingCard();

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LoadingBox(width: 38, height: 38),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LoadingBox(width: 160, height: 14),
                SizedBox(height: 8),
                _LoadingBox(width: 128, height: 11),
                SizedBox(height: 8),
                _LoadingBox(width: 112, height: 11),
              ],
            ),
          ),
          SizedBox(width: 12),
          _LoadingBox(width: 28, height: 14),
        ],
      ),
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

class _DisciplineEmptyView extends StatelessWidget {
  const _DisciplineEmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.fact_check_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
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

class _DisciplineFailure extends StatelessWidget {
  const _DisciplineFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisciplineItem {
  const _DisciplineItem({
    required this.description,
    required this.point,
    required this.date,
    required this.schoolSession,
    required this.semester,
    required this.teacherName,
    required this.isMerit,
  });

  factory _DisciplineItem.fromMerit(MeritEntity merit) {
    return _DisciplineItem(
      description: merit.description,
      point: merit.point,
      date: merit.date,
      schoolSession: merit.schoolSession,
      semester: merit.semester,
      teacherName: merit.teacherName,
      isMerit: true,
    );
  }

  factory _DisciplineItem.fromDemerit(DemeritEntity demerit) {
    return _DisciplineItem(
      description: demerit.description,
      point: demerit.point,
      date: demerit.date,
      schoolSession: demerit.schoolSession,
      semester: demerit.semester,
      teacherName: demerit.teacherName,
      isMerit: false,
    );
  }

  final String description;
  final int point;
  final DateTime date;
  final String schoolSession;
  final String semester;
  final String teacherName;
  final bool isMerit;
}
