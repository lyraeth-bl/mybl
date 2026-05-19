// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
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
  String? _selectedMeritSchoolSession;
  String? _selectedMeritSemester;
  String? _selectedDemeritSchoolSession;
  String? _selectedDemeritSemester;

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
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainer,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            const _MeritDemeritHeader(),
          ],
          body: TabBarView(
            children: [
              _MeritTab(
                selectedSchoolSession: _selectedMeritSchoolSession,
                selectedSemester: _selectedMeritSemester,
                onSchoolSessionChanged: (value) {
                  setState(() => _selectedMeritSchoolSession = value);
                },
                onSemesterChanged: (value) {
                  setState(() => _selectedMeritSemester = value);
                },
              ),
              _DemeritTab(
                selectedSchoolSession: _selectedDemeritSchoolSession,
                selectedSemester: _selectedDemeritSemester,
                onSchoolSessionChanged: (value) {
                  setState(() => _selectedDemeritSchoolSession = value);
                },
                onSemesterChanged: (value) {
                  setState(() => _selectedDemeritSemester = value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeritDemeritHeader extends StatelessWidget {
  const _MeritDemeritHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar.medium(
      title: Text(
        l10n.meritAndDemerit,
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: colorScheme.primaryContainer,
      centerTitle: true,
      pinned: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      bottom: TabBar(
        labelColor: colorScheme.onPrimaryContainer,
        unselectedLabelColor: colorScheme.onPrimaryContainer.withValues(
          alpha: 0.68,
        ),
        indicatorColor: colorScheme.primary,
        tabs: [
          Tab(text: l10n.merit),
          Tab(text: l10n.demerit),
        ],
      ),
    );
  }
}

class _MeritTab extends StatelessWidget {
  const _MeritTab({
    required this.selectedSchoolSession,
    required this.selectedSemester,
    required this.onSchoolSessionChanged,
    required this.onSemesterChanged,
  });

  final String? selectedSchoolSession;
  final String? selectedSemester;
  final ValueChanged<String?> onSchoolSessionChanged;
  final ValueChanged<String?> onSemesterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshWrapper(
      onRefresh: () => blocRefresh<MeritBloc, MeritEvent, MeritState>(
        context: context,
        event: const MeritEvent.fetchMerit(forceRefresh: true),
        isDone: (state) => state.maybeWhen(
          success: (_) => true,
          emptyData: () => true,
          failure: (_) => true,
          orElse: () => false,
        ),
      ),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          BlocBuilder<MeritBloc, MeritState>(
            builder: (context, state) {
              return state.maybeWhen(
                loading: () => const _DisciplineLoadingBody(),
                success: (listMerit) {
                  final filteredMerit = _filterMerit(listMerit);

                  return _DisciplineContent(
                    defaultPoint: 0,
                    totalPoint: _totalMeritPoint(listMerit),
                    schoolSessions: _schoolSessionsFromMerit(listMerit),
                    semesters: _semestersFromMerit(listMerit),
                    selectedSchoolSession: selectedSchoolSession,
                    selectedSemester: selectedSemester,
                    onSchoolSessionChanged: onSchoolSessionChanged,
                    onSemesterChanged: onSemesterChanged,
                    cards: filteredMerit
                        .map<Widget>(
                          (merit) => _DisciplineCard(
                            description: merit.description,
                            point: merit.point,
                            date: merit.date.toDayMonthYearFormat,
                            schoolSession: merit.schoolSession,
                            semester: merit.semester,
                            teacherName: merit.teacherName,
                            unit: merit.unit,
                            isMerit: true,
                          ),
                        )
                        .toList()
                        .makeListAnimate(),
                    emptyMessage: l10n.noDisciplineData,
                  );
                },
                emptyData: () => _DisciplineContent(
                  defaultPoint: 0,
                  totalPoint: 0,
                  schoolSessions: const [],
                  semesters: const [],
                  selectedSchoolSession: selectedSchoolSession,
                  selectedSemester: selectedSemester,
                  onSchoolSessionChanged: onSchoolSessionChanged,
                  onSemesterChanged: onSemesterChanged,
                  cards: const [],
                  emptyMessage: l10n.noDisciplineData,
                ),
                failure: (failure) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: _DisciplineFailure(
                    message: failure.localizedMessage(l10n),
                    onRetry: () => context.read<MeritBloc>().add(
                      const MeritEvent.fetchMerit(forceRefresh: true),
                    ),
                  ),
                ),
                orElse: () => const _DisciplineLoadingBody(),
              );
            },
          ),
        ],
      ),
    );
  }

  List<MeritEntity> _filterMerit(List<MeritEntity> listMerit) {
    return listMerit.where((merit) {
      final matchesSchoolSession =
          selectedSchoolSession == null ||
          merit.schoolSession == selectedSchoolSession;
      final matchesSemester =
          selectedSemester == null || merit.semester == selectedSemester;

      return matchesSchoolSession && matchesSemester;
    }).toList();
  }

  int _totalMeritPoint(List<MeritEntity> listMerit) =>
      listMerit.fold(0, (total, merit) => total + merit.point);

  List<String> _schoolSessionsFromMerit(List<MeritEntity> listMerit) {
    final schoolSessions = listMerit
        .map((merit) => merit.schoolSession)
        .toSet()
        .toList();
    schoolSessions.sort((a, b) => b.compareTo(a));
    return schoolSessions;
  }

  List<String> _semestersFromMerit(List<MeritEntity> listMerit) {
    final semesters = listMerit.map((merit) => merit.semester).toSet().toList();
    semesters.sort();
    return semesters;
  }
}

class _DemeritTab extends StatelessWidget {
  const _DemeritTab({
    required this.selectedSchoolSession,
    required this.selectedSemester,
    required this.onSchoolSessionChanged,
    required this.onSemesterChanged,
  });

  final String? selectedSchoolSession;
  final String? selectedSemester;
  final ValueChanged<String?> onSchoolSessionChanged;
  final ValueChanged<String?> onSemesterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshWrapper(
      onRefresh: () => blocRefresh<DemeritBloc, DemeritEvent, DemeritState>(
        context: context,
        event: const DemeritEvent.fetchDemerit(forceRefresh: true),
        isDone: (state) => state.maybeWhen(
          success: (_) => true,
          emptyData: () => true,
          failure: (_) => true,
          orElse: () => false,
        ),
      ),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          BlocBuilder<DemeritBloc, DemeritState>(
            builder: (context, state) {
              return state.maybeWhen(
                loading: () => const _DisciplineLoadingBody(),
                success: (listDemerit) {
                  final filteredDemerit = _filterDemerit(listDemerit);

                  return _DisciplineContent(
                    defaultPoint: 100,
                    totalPoint: _totalDemeritPoint(listDemerit),
                    schoolSessions: _schoolSessionsFromDemerit(listDemerit),
                    semesters: _semestersFromDemerit(listDemerit),
                    selectedSchoolSession: selectedSchoolSession,
                    selectedSemester: selectedSemester,
                    onSchoolSessionChanged: onSchoolSessionChanged,
                    onSemesterChanged: onSemesterChanged,
                    cards: filteredDemerit
                        .map<Widget>(
                          (demerit) => _DisciplineCard(
                            description: demerit.description,
                            point: demerit.point,
                            date: demerit.date.toDayMonthYearFormat,
                            schoolSession: demerit.schoolSession,
                            semester: demerit.semester,
                            teacherName: demerit.teacherName,
                            unit: demerit.unit,
                            isMerit: false,
                          ),
                        )
                        .toList()
                        .makeListAnimate(),
                    emptyMessage: l10n.noDisciplineData,
                  );
                },
                emptyData: () => _DisciplineContent(
                  defaultPoint: 100,
                  totalPoint: 100,
                  schoolSessions: const [],
                  semesters: const [],
                  selectedSchoolSession: selectedSchoolSession,
                  selectedSemester: selectedSemester,
                  onSchoolSessionChanged: onSchoolSessionChanged,
                  onSemesterChanged: onSemesterChanged,
                  cards: const [],
                  emptyMessage: l10n.noDisciplineData,
                ),
                failure: (failure) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: _DisciplineFailure(
                    message: failure.localizedMessage(l10n),
                    onRetry: () => context.read<DemeritBloc>().add(
                      const DemeritEvent.fetchDemerit(forceRefresh: true),
                    ),
                  ),
                ),
                orElse: () => const _DisciplineLoadingBody(),
              );
            },
          ),
        ],
      ),
    );
  }

  List<DemeritEntity> _filterDemerit(List<DemeritEntity> listDemerit) {
    return listDemerit.where((demerit) {
      final matchesSchoolSession =
          selectedSchoolSession == null ||
          demerit.schoolSession == selectedSchoolSession;
      final matchesSemester =
          selectedSemester == null || demerit.semester == selectedSemester;

      return matchesSchoolSession && matchesSemester;
    }).toList();
  }

  int _totalDemeritPoint(List<DemeritEntity> listDemerit) {
    final usedPoint = listDemerit.fold(
      0,
      (total, demerit) => total + demerit.point,
    );

    return 100 - usedPoint;
  }

  List<String> _schoolSessionsFromDemerit(List<DemeritEntity> listDemerit) {
    final schoolSessions = listDemerit
        .map((demerit) => demerit.schoolSession)
        .toSet()
        .toList();
    schoolSessions.sort((a, b) => b.compareTo(a));
    return schoolSessions;
  }

  List<String> _semestersFromDemerit(List<DemeritEntity> listDemerit) {
    final semesters = listDemerit
        .map((demerit) => demerit.semester)
        .toSet()
        .toList();
    semesters.sort();
    return semesters;
  }
}

class _DisciplineContent extends StatelessWidget {
  const _DisciplineContent({
    required this.defaultPoint,
    required this.totalPoint,
    required this.schoolSessions,
    required this.semesters,
    required this.selectedSchoolSession,
    required this.selectedSemester,
    required this.onSchoolSessionChanged,
    required this.onSemesterChanged,
    required this.cards,
    required this.emptyMessage,
  });

  final int defaultPoint;
  final int totalPoint;
  final List<String> schoolSessions;
  final List<String> semesters;
  final String? selectedSchoolSession;
  final String? selectedSemester;
  final ValueChanged<String?> onSchoolSessionChanged;
  final ValueChanged<String?> onSemesterChanged;
  final List<Widget> cards;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final children = [
      _PointSummary(defaultPoint: defaultPoint, totalPoint: totalPoint),
      _DisciplineFilters(
        schoolSessions: schoolSessions,
        semesters: semesters,
        selectedSchoolSession: selectedSchoolSession,
        selectedSemester: selectedSemester,
        onSchoolSessionChanged: onSchoolSessionChanged,
        onSemesterChanged: onSemesterChanged,
      ),
      if (cards.isEmpty)
        _DisciplineEmptyView(message: emptyMessage)
      else
        ...cards,
      const SizedBox(height: 24),
    ];

    return SliverList.list(children: children);
  }
}

class _PointSummary extends StatelessWidget {
  const _PointSummary({required this.defaultPoint, required this.totalPoint});

  final int defaultPoint;
  final int totalPoint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _PointCard(
              label: l10n.defaultPoint,
              point: defaultPoint,
              icon: Icons.flag_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PointCard(
              label: l10n.totalPoint,
              point: totalPoint,
              icon: Icons.stars_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  const _PointCard({
    required this.label,
    required this.point,
    required this.icon,
  });

  final String label;
  final int point;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.filled(
      color: colorScheme.primaryContainer,
      shape: const RoundedRectangleBorder(borderRadius: customRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.onPrimaryContainer),
            const SizedBox(height: 12),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: point),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  value.toString(),
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DisciplineFilters extends StatelessWidget {
  const _DisciplineFilters({
    required this.schoolSessions,
    required this.semesters,
    required this.selectedSchoolSession,
    required this.selectedSemester,
    required this.onSchoolSessionChanged,
    required this.onSemesterChanged,
  });

  final List<String> schoolSessions;
  final List<String> semesters;
  final String? selectedSchoolSession;
  final String? selectedSemester;
  final ValueChanged<String?> onSchoolSessionChanged;
  final ValueChanged<String?> onSemesterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _FilterDropdown(
              label: l10n.schoolYear,
              icon: Icons.calendar_month_outlined,
              value: selectedSchoolSession,
              allLabel: l10n.allSchoolYears,
              values: schoolSessions,
              onChanged: onSchoolSessionChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FilterDropdown(
              label: l10n.semester,
              icon: Icons.event_note_outlined,
              value: selectedSemester,
              allLabel: l10n.allSemesters,
              values: semesters,
              onChanged: onSemesterChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.allLabel,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String? value;
  final String allLabel;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(icon),
        prefixIconColor: colorScheme.primary,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 38,
          minHeight: 38,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: customRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: customRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: customRadius,
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(
            allLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
          ),
        ),
        ...values.map(
          (value) => DropdownMenuItem<String?>(
            value: value,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _DisciplineCard extends StatelessWidget {
  const _DisciplineCard({
    required this.description,
    required this.point,
    required this.date,
    required this.schoolSession,
    required this.semester,
    required this.teacherName,
    required this.unit,
    required this.isMerit,
  });

  final String description;
  final int point;
  final String date;
  final String schoolSession;
  final String semester;
  final String teacherName;
  final String unit;
  final bool isMerit;

  @override
  Widget build(BuildContext context) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    description,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _DisciplinePointBadge(point: point, isMerit: isMerit),
              ],
            ),
            const SizedBox(height: 16),
            _DisciplineInfoGrid(
              date: date,
              schoolSession: schoolSession,
              semester: semester,
              unit: unit,
              teacherName: teacherName,
            ),
          ],
        ),
      ),
    );
  }
}

class _DisciplinePointBadge extends StatelessWidget {
  const _DisciplinePointBadge({required this.point, required this.isMerit});

  final int point;
  final bool isMerit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final backgroundColor = isMerit
        ? colorScheme.tertiaryContainer
        : colorScheme.errorContainer;
    final foregroundColor = isMerit
        ? colorScheme.onTertiaryContainer
        : colorScheme.onErrorContainer;
    final pointPrefix = isMerit ? '+' : '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: const RoundedRectangleBorder(borderRadius: customRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.point,
            style: textTheme.labelSmall?.copyWith(color: foregroundColor),
          ),
          Text(
            '$pointPrefix$point',
            style: textTheme.titleMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DisciplineInfoGrid extends StatelessWidget {
  const _DisciplineInfoGrid({
    required this.date,
    required this.schoolSession,
    required this.semester,
    required this.unit,
    required this.teacherName,
  });

  final String date;
  final String schoolSession;
  final String semester;
  final String unit;
  final String teacherName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.35,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _InfoTile(
              icon: Icons.calendar_today_outlined,
              label: l10n.date,
              value: date,
            ),
            _InfoTile(
              icon: Icons.school_outlined,
              label: l10n.schoolYear,
              value: schoolSession,
            ),
            _InfoTile(
              icon: Icons.event_note_outlined,
              label: l10n.semester,
              value: semester,
            ),
            _InfoTile(
              icon: Icons.apartment_outlined,
              label: l10n.unit,
              value: unit,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _InfoTile(
          icon: Icons.person_outline,
          label: l10n.teacher,
          value: teacherName,
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
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
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
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

class _DisciplineLoadingBody extends StatelessWidget {
  const _DisciplineLoadingBody();

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: const [
        _PointSummaryLoading(),
        _FilterLoading(),
        _DisciplineLoadingCard(),
        _DisciplineLoadingCard(),
        _DisciplineLoadingCard(),
        SizedBox(height: 24),
      ],
    );
  }
}

class _PointSummaryLoading extends StatelessWidget {
  const _PointSummaryLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(child: _LoadingBox(height: 132, borderRadius: customRadius)),
          const SizedBox(width: 12),
          Expanded(child: _LoadingBox(height: 132, borderRadius: customRadius)),
        ],
      ),
    );
  }
}

class _FilterLoading extends StatelessWidget {
  const _FilterLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(child: _LoadingBox(height: 64, borderRadius: customRadius)),
          SizedBox(width: 12),
          Expanded(child: _LoadingBox(height: 64, borderRadius: customRadius)),
        ],
      ),
    );
  }
}

class _DisciplineLoadingCard extends StatelessWidget {
  const _DisciplineLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: const RoundedRectangleBorder(borderRadius: customRadius),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _LoadingBox(height: 22)),
                SizedBox(width: 12),
                _LoadingBox(width: 56, height: 44, borderRadius: customRadius),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _LoadingBox(width: 118, height: 52),
                _LoadingBox(width: 118, height: 52),
                _LoadingBox(width: 118, height: 52),
                _LoadingBox(width: 118, height: 52),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox({this.width, required this.height, this.borderRadius});

  final double? width;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return const SizedBox().toShimmer(
      context,
      width: width ?? double.infinity,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
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
