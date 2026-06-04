// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
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
        backgroundColor: colorScheme.primaryContainer,
        appBar: const _MeritDemeritAppBar(),
        body: const _MeritDemeritBody(),
      ),
    );
  }
}

class _MeritDemeritAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _MeritDemeritAppBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: colorScheme.primaryContainer,
      surfaceTintColor: colorScheme.primaryContainer,
      toolbarHeight: 72,
      title: Text(
        l10n.meritAndDemerit,
        style: const TextStyle(fontWeight: .bold, letterSpacing: 2),
      ),
      centerTitle: true,
      bottom: TabBar(
        dividerColor: colorScheme.primaryContainer,
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

  @override
  Size get preferredSize => const Size.fromHeight(128);
}

class _MeritDemeritBody extends StatelessWidget {
  const _MeritDemeritBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: const TabBarView(children: [_MeritTab(), _DemeritTab()]),
    );
  }
}

class _MeritTab extends StatefulWidget {
  const _MeritTab();

  @override
  State<_MeritTab> createState() => _MeritTabState();
}

class _MeritTabState extends State<_MeritTab> {
  String? _selectedSchoolSession;
  String? _selectedSemester;

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
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          BlocBuilder<MeritBloc, MeritState>(
            builder: (context, state) {
              return state.maybeWhen(
                loading: () => const _DisciplineLoadingContent(),
                success: (merits) {
                  final items = merits.map(_DisciplineItem.fromMerit).toList();

                  return _DisciplineContent(
                    defaultPoint: 0,
                    totalPoint: _totalMeritPoint(merits),
                    items: items,
                    filteredItems: _filterItems(items),
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
                emptyData: () => _DisciplineContent(
                  defaultPoint: 0,
                  totalPoint: 0,
                  items: const [],
                  filteredItems: const [],
                  selectedSchoolSession: _selectedSchoolSession,
                  selectedSemester: _selectedSemester,
                  onSchoolSessionChanged: (value) {
                    setState(() => _selectedSchoolSession = value);
                  },
                  onSemesterChanged: (value) {
                    setState(() => _selectedSemester = value);
                  },
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
                orElse: () => const _DisciplineLoadingContent(),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
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

  int _totalMeritPoint(List<MeritEntity> merits) {
    return merits.fold(0, (total, merit) => total + merit.point);
  }
}

class _DemeritTab extends StatefulWidget {
  const _DemeritTab();

  @override
  State<_DemeritTab> createState() => _DemeritTabState();
}

class _DemeritTabState extends State<_DemeritTab> {
  String? _selectedSchoolSession;
  String? _selectedSemester;

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
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          BlocBuilder<DemeritBloc, DemeritState>(
            builder: (context, state) {
              return state.maybeWhen(
                loading: () => const _DisciplineLoadingContent(),
                success: (demerits) {
                  final items = demerits
                      .map(_DisciplineItem.fromDemerit)
                      .toList();

                  return _DisciplineContent(
                    defaultPoint: 100,
                    totalPoint: _totalDemeritPoint(demerits),
                    items: items,
                    filteredItems: _filterItems(items),
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
                emptyData: () => _DisciplineContent(
                  defaultPoint: 100,
                  totalPoint: 100,
                  items: const [],
                  filteredItems: const [],
                  selectedSchoolSession: _selectedSchoolSession,
                  selectedSemester: _selectedSemester,
                  onSchoolSessionChanged: (value) {
                    setState(() => _selectedSchoolSession = value);
                  },
                  onSemesterChanged: (value) {
                    setState(() => _selectedSemester = value);
                  },
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
                orElse: () => const _DisciplineLoadingContent(),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
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

  int _totalDemeritPoint(List<DemeritEntity> demerits) {
    final usedPoint = demerits.fold(
      0,
      (total, demerit) => total + demerit.point,
    );

    return 100 - usedPoint;
  }
}

class _DisciplineContent extends StatelessWidget {
  const _DisciplineContent({
    required this.defaultPoint,
    required this.totalPoint,
    required this.items,
    required this.filteredItems,
    required this.selectedSchoolSession,
    required this.selectedSemester,
    required this.onSchoolSessionChanged,
    required this.onSemesterChanged,
    required this.emptyMessage,
  });

  final int defaultPoint;
  final int totalPoint;
  final List<_DisciplineItem> items;
  final List<_DisciplineItem> filteredItems;
  final String? selectedSchoolSession;
  final String? selectedSemester;
  final ValueChanged<String?> onSchoolSessionChanged;
  final ValueChanged<String?> onSemesterChanged;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItems(filteredItems);

    return SliverMainAxisGroup(
      slivers: [
        _PointSection(defaultPoint: defaultPoint, totalPoint: totalPoint),
        _FilterSection(
          schoolSessions: _schoolSessions(items),
          semesters: _semesters(items),
          selectedSchoolSession: selectedSchoolSession,
          selectedSemester: selectedSemester,
          onSchoolSessionChanged: onSchoolSessionChanged,
          onSemesterChanged: onSemesterChanged,
        ),
        if (groupedItems.isEmpty)
          SliverToBoxAdapter(child: _DisciplineEmptyView(message: emptyMessage))
        else
          ...groupedItems.map((group) => _DisciplineGroupSection(group: group)),
      ],
    );
  }

  List<_DisciplineGroup> _groupItems(List<_DisciplineItem> items) {
    final grouped = <String, List<_DisciplineItem>>{};

    for (final item in items) {
      final key = '${item.schoolSession}|${item.semester}';
      grouped.putIfAbsent(key, () => <_DisciplineItem>[]).add(item);
    }

    final groups = grouped.entries.map((entry) {
      final firstItem = entry.value.first;
      final sortedItems = [...entry.value]
        ..sort((a, b) => b.date.compareTo(a.date));

      return _DisciplineGroup(
        schoolSession: firstItem.schoolSession,
        semester: firstItem.semester,
        items: sortedItems,
      );
    }).toList();

    groups.sort((a, b) {
      final schoolSessionOrder = b.schoolSession.compareTo(a.schoolSession);
      if (schoolSessionOrder != 0) return schoolSessionOrder;

      return a.semester.compareTo(b.semester);
    });

    return groups;
  }

  List<String> _schoolSessions(List<_DisciplineItem> items) {
    final schoolSessions = items
        .map((item) => item.schoolSession)
        .toSet()
        .toList();
    schoolSessions.sort((a, b) => b.compareTo(a));
    return schoolSessions;
  }

  List<String> _semesters(List<_DisciplineItem> items) {
    final semesters = items.map((item) => item.semester).toSet().toList();
    semesters.sort();
    return semesters;
  }
}

class _PointSection extends StatelessWidget {
  const _PointSection({required this.defaultPoint, required this.totalPoint});

  final int defaultPoint;
  final int totalPoint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSliverGroup(
      title: l10n.point,
      titleStyle: textTheme.titleMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

    return AppContainer(
      margin: EdgeInsets.zero,
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
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: point),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                value.toString(),
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSliverGroup(
      title: '${l10n.schoolYear} & ${l10n.semester}',
      titleStyle: textTheme.titleMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AppContainer(
        margin: EdgeInsets.zero,
        elevation: 0,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.surfaceContainerHighest,
            offset: const Offset(5, 5),
          ),
        ],
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ],
        ),
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
    required this.borderRadius,
  });

  final String label;
  final IconData icon;
  final String? value;
  final String allLabel;
  final List<String> values;
  final ValueChanged<String?> onChanged;
  final BorderRadius borderRadius;

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
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
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

class _DisciplineGroupSection extends StatelessWidget {
  const _DisciplineGroupSection({required this.group});

  final _DisciplineGroup group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSliverGroup(
      title: '${group.schoolSession} - ${l10n.semester} ${group.semester}',
      action: _GroupPointTotal(group: group),
      pinned: true,
      backgroundColor: colorScheme.surfaceContainer,
      titleStyle: textTheme.titleMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      headerPadding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList.list(
        children: group.items
            .asMap()
            .entries
            .map(
              (entry) => _DisciplineCard(
                item: entry.value,
                shape: _disciplineCardShape(entry.key, group.items.length - 1),
              ),
            )
            .toList()
            .makeListAnimate(),
      ),
    );
  }

  ShapeBorder _disciplineCardShape(int index, int lastIndex) {
    if (lastIndex == 0) {
      return RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
    }

    return index.makeVerticalGoogleShape(lastIndex);
  }
}

class _GroupPointTotal extends StatelessWidget {
  const _GroupPointTotal({required this.group});

  final _DisciplineGroup group;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMerit = group.items.firstOrNull?.isMerit ?? true;
    final totalPoint = group.items.fold(0, (total, item) => total + item.point);
    final backgroundColor = isMerit
        ? colorScheme.tertiaryContainer
        : colorScheme.errorContainer;
    final foregroundColor = isMerit
        ? colorScheme.onTertiaryContainer
        : colorScheme.onErrorContainer;
    final prefix = isMerit ? '+' : '-';

    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        '$prefix$totalPoint',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: textTheme.labelLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DisciplineCard extends StatelessWidget {
  const _DisciplineCard({required this.item, required this.shape});

  final _DisciplineItem item;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: shape,
      borderRadius: null,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _DisciplinePointBadge(point: item.point, isMerit: item.isMerit),
            ],
          ),
          const SizedBox(height: 14),
          _DisciplineMetaRow(
            icon: Icons.calendar_today_outlined,
            label: l10n.date,
            value: item.date.toDayMonthYearFormat,
          ),
          const SizedBox(height: 10),
          _DisciplineMetaRow(
            icon: Icons.event_note_outlined,
            label: l10n.semester,
            value: item.semester,
          ),
          const SizedBox(height: 10),
          _DisciplineMetaRow(
            icon: Icons.person_outline,
            label: l10n.teacher,
            value: item.teacherName,
          ),
        ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(
        '$pointPrefix$point',
        style: textTheme.titleSmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DisciplineMetaRow extends StatelessWidget {
  const _DisciplineMetaRow({
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

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DisciplineLoadingContent extends StatelessWidget {
  const _DisciplineLoadingContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverMainAxisGroup(
      slivers: [
        AppSliverGroup(
          title: AppLocalizations.of(context)!.point,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            children: const [
              Expanded(child: _PointLoadingCard()),
              SizedBox(width: 12),
              Expanded(child: _PointLoadingCard()),
            ],
          ),
        ),
        AppSliverGroup(
          title:
              '${AppLocalizations.of(context)!.schoolYear} & '
              '${AppLocalizations.of(context)!.semester}',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: AppContainer(
            margin: EdgeInsets.zero,
            elevation: 0,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.surfaceContainerHighest,
                offset: const Offset(5, 5),
              ),
            ],
            child: const Row(
              children: [
                Expanded(child: _LoadingBox(height: 56)),
                SizedBox(width: 12),
                Expanded(child: _LoadingBox(height: 56)),
              ],
            ),
          ),
        ),
        AppSliverGroup(
          title: AppLocalizations.of(context)!.meritAndDemerit,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          sliver: SliverList.list(
            children: const [
              _DisciplineLoadingCard(),
              _DisciplineLoadingCard(),
              _DisciplineLoadingCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _PointLoadingCard extends StatelessWidget {
  const _PointLoadingCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: EdgeInsets.zero,
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
          _LoadingBox(width: 22, height: 22),
          SizedBox(height: 16),
          _LoadingBox(width: 72, height: 12),
          SizedBox(height: 8),
          _LoadingBox(width: 48, height: 28),
        ],
      ),
    );
  }
}

class _DisciplineLoadingCard extends StatelessWidget {
  const _DisciplineLoadingCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: const EdgeInsets.symmetric(vertical: 2),
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
          Row(
            children: [
              Expanded(child: _LoadingBox(height: 18)),
              SizedBox(width: 12),
              _LoadingBox(width: 48, height: 32),
            ],
          ),
          SizedBox(height: 16),
          _LoadingBox(width: 160, height: 12),
          SizedBox(height: 10),
          _LoadingBox(width: 96, height: 12),
          SizedBox(height: 10),
          _LoadingBox(width: 140, height: 12),
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

class _DisciplineGroup {
  const _DisciplineGroup({
    required this.schoolSession,
    required this.semester,
    required this.items,
  });

  final String schoolSession;
  final String semester;
  final List<_DisciplineItem> items;
}
