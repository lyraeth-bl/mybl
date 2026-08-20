// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/discipline.dart';
import '../bloc/demerit_bloc/demerit_bloc.dart';
import '../bloc/merit_bloc/merit_bloc.dart';
import '../widgets/discipline_activity_card.dart';
import '../widgets/discipline_filter_section.dart';
import '../widgets/discipline_item.dart';
import '../widgets/discipline_state_widgets.dart';
import '../widgets/discipline_summary_section.dart';

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
      context.read<MeritBloc>().add(const .fetchMerit());
      context.read<DemeritBloc>().add(const .fetchDemerit());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
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

    return AppTopBar(toolbarHeight: 72, title: Text(l10n.meritAndDemerit));
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
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

    return Future.wait([meritRefresh, demeritRefresh]);
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
                      child: DisciplineFailure(
                        message: failure.localizedMessage(l10n),
                        onRetry: () {
                          context.read<MeritBloc>().add(
                            const .fetchMerit(forceRefresh: true),
                          );
                          context.read<DemeritBloc>().add(
                            const .fetchDemerit(forceRefresh: true),
                          );
                        },
                      ),
                    );
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
                    ...merits.map(DisciplineItem.fromMerit),
                    ...demerits.map(DisciplineItem.fromDemerit),
                  ]..sort((a, b) => b.date.compareTo(a.date));
                  final schoolSessions = _schoolSessions(items);
                  final schoolSession = _resolveSchoolSession(schoolSessions);
                  final semesters = _semesters(items, schoolSession);
                  final semester = _resolveSemester(semesters);
                  final filteredItems = isLoading
                      ? List<DisciplineItem>.generate(
                          3,
                          DisciplineItem.placeholder,
                        )
                      : _itemsForPeriod(items, schoolSession, semester);

                  return _DisciplineContent(
                    filteredItems: filteredItems,
                    isLoading: isLoading,
                    schoolSessions: schoolSessions,
                    semesters: semesters,
                    selectedSchoolSession: schoolSession,
                    selectedSemester: semester,
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

  /// Falls back to the newest school year whenever the user has not picked one
  /// yet, or their pick is no longer present in the freshly fetched data.
  String _resolveSchoolSession(List<String> schoolSessions) {
    if (schoolSessions.contains(_selectedSchoolSession)) {
      return _selectedSchoolSession!;
    }

    return schoolSessions.isEmpty ? '' : schoolSessions.first;
  }

  /// Falls back to the latest semester available within the selected school
  /// year, since the discipline point only resets per semester.
  String _resolveSemester(List<String> semesters) {
    if (semesters.contains(_selectedSemester)) return _selectedSemester!;

    return semesters.isEmpty ? '' : semesters.last;
  }

  static List<DisciplineItem> _itemsForPeriod(
    List<DisciplineItem> items,
    String schoolSession,
    String semester,
  ) {
    return items
        .where(
          (item) =>
              item.schoolSession == schoolSession && item.semester == semester,
        )
        .toList();
  }

  static List<String> _schoolSessions(List<DisciplineItem> items) {
    final schoolSessions = items
        .map((item) => item.schoolSession)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList();
    schoolSessions.sort((a, b) => b.compareTo(a));
    return schoolSessions;
  }

  static List<String> _semesters(
    List<DisciplineItem> items,
    String schoolSession,
  ) {
    final semesters = items
        .where((item) => item.schoolSession == schoolSession)
        .map((item) => item.semester)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList();
    semesters.sort();
    return semesters;
  }
}

class _DisciplineContent extends StatelessWidget {
  const _DisciplineContent({
    required this.filteredItems,
    required this.isLoading,
    required this.schoolSessions,
    required this.semesters,
    required this.selectedSchoolSession,
    required this.selectedSemester,
    required this.onSchoolSessionChanged,
    required this.onSemesterChanged,
    required this.emptyMessage,
  });

  final List<DisciplineItem> filteredItems;
  final bool isLoading;
  final List<String> schoolSessions;
  final List<String> semesters;
  final String selectedSchoolSession;
  final String selectedSemester;
  final ValueChanged<String> onSchoolSessionChanged;
  final ValueChanged<String> onSemesterChanged;
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
        DisciplineSummarySection(
          meritPoint: meritPoint,
          demeritPoint: demeritPoint,
          isLoading: isLoading,
        ),
        DisciplineFilterGroup(
          schoolSessions: schoolSessions,
          semesters: semesters,
          selectedSchoolSession: selectedSchoolSession,
          selectedSemester: selectedSemester,
          onSchoolSessionChanged: onSchoolSessionChanged,
          onSemesterChanged: onSemesterChanged,
          activityCount: filteredItems.length,
          isLoading: isLoading,
          sliver: filteredItems.isEmpty
              ? SliverToBoxAdapter(
                  child: DisciplineEmptyView(message: emptyMessage),
                )
              : SliverList.list(
                  children: filteredItems
                      .map(
                        (item) => DisciplineActivityCard(
                          item: item,
                          isLoading: isLoading,
                        ),
                      )
                      .toList()
                      .makeListAnimate(),
                ),
        ),
        SliverToBoxAdapter(child: 24.h),
      ],
    );
  }
}
