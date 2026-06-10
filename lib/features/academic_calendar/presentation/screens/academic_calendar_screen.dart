// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../bloc/academic_calendar_bloc.dart';
import '../widgets/academic_calendar_event_list_section.dart';
import '../widgets/academic_calendar_month_section.dart';

class AcademicCalendarScreen extends StatelessWidget {
  const AcademicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AcademicCalendarBloc>(
      create: (context) => di<AcademicCalendarBloc>(),
      child: const _AcademicCalendarView(),
    );
  }
}

class _AcademicCalendarView extends StatefulWidget {
  const _AcademicCalendarView();

  @override
  State<_AcademicCalendarView> createState() => _AcademicCalendarViewState();
}

class _AcademicCalendarViewState extends State<_AcademicCalendarView> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final unit = _currentStudentUnit(context);
      if (unit == null) {
        context.read<UserBloc>().add(const UserEvent.fetchStudentRequested());
        return;
      }

      _fetchAcademicCalendar(unit: unit);
    });
  }

  String? _currentStudentUnit(BuildContext context) {
    final unit = context.read<UserBloc>().state.maybeWhen(
      success: (student) => student.unit?.trim(),
      orElse: () => null,
    );

    if (unit == null || unit.isEmpty) return null;
    return unit;
  }

  void _fetchAcademicCalendar({
    required String unit,
    bool forceRefresh = false,
  }) {
    context.read<AcademicCalendarBloc>().add(
      AcademicCalendarEvent.fetchAcademicCalendar(
        year: _focusedMonth.year,
        month: _focusedMonth.month,
        unit: unit,
        forceRefresh: forceRefresh,
      ),
    );
  }

  void _moveMonth(int offset) {
    final unit = _currentStudentUnit(context);
    if (unit == null) return;

    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
      );
    });
    _fetchAcademicCalendar(unit: unit);
  }

  Future<void> _refresh() {
    final unit = _currentStudentUnit(context);
    if (unit == null) return Future<void>.value();

    return blocRefresh<
      AcademicCalendarBloc,
      AcademicCalendarEvent,
      AcademicCalendarState
    >(
      context: context,
      event: AcademicCalendarEvent.fetchAcademicCalendar(
        year: _focusedMonth.year,
        month: _focusedMonth.month,
        unit: unit,
        forceRefresh: true,
      ),
      isDone: (state) => state.maybeWhen(
        success: (_, _, _) => true,
        emptyData: () => true,
        failure: (_) => true,
        orElse: () => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (previous, current) {
        final previousUnit = previous.maybeWhen(
          success: (student) => student.unit,
          orElse: () => null,
        );
        final currentUnit = current.maybeWhen(
          success: (student) => student.unit,
          orElse: () => null,
        );

        return previousUnit != currentUnit && currentUnit != null;
      },
      listener: (context, state) {
        final unit = _currentStudentUnit(context);
        if (unit != null) _fetchAcademicCalendar(unit: unit);
      },
      child: Scaffold(
        appBar: const _AcademicCalendarAppBar(),
        body: _AcademicCalendarBody(
          focusedMonth: _focusedMonth,
          onPrevious: () => _moveMonth(-1),
          onNext: () => _moveMonth(1),
          onRefresh: _refresh,
        ),
      ),
    );
  }
}

@immutable
class _AcademicCalendarAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _AcademicCalendarAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(
      toolbarHeight: 72,
      title: Text(l10n.academicCalendar),
      centerTitle: true,
      actions: [const _AcademicCalendarProfileAction()],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class _AcademicCalendarProfileAction extends StatelessWidget {
  const _AcademicCalendarProfileAction();

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

class _AcademicCalendarBody extends StatelessWidget {
  const _AcademicCalendarBody({
    required this.focusedMonth,
    required this.onPrevious,
    required this.onNext,
    required this.onRefresh,
  });

  final DateTime focusedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          AcademicCalendarMonthSection(
            focusedMonth: focusedMonth,
            onPrevious: onPrevious,
            onNext: onNext,
          ),
          const AcademicCalendarEventListSection(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
