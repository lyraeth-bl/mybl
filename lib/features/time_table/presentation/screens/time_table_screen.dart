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
import '../../../user/presentation/bloc/user_bloc.dart';
import '../bloc/time_table_bloc.dart';
import '../widgets/time_table_day_selector.dart';
import '../widgets/time_table_schedule_groups_section.dart';

class TimeTableScreen extends StatelessWidget {
  const TimeTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TimeTableBloc>(
      create: (context) => di<TimeTableBloc>(),
      child: const _TimeTableView(),
    );
  }
}

class _TimeTableView extends StatefulWidget {
  const _TimeTableView();

  @override
  State<_TimeTableView> createState() => _TimeTableViewState();
}

class _TimeTableViewState extends State<_TimeTableView> {
  String _studentClass(BuildContext context) {
    return context.read<UserBloc>().state.maybeWhen(
      success: (student) => '${student.kelasSaatIni}${student.noKelasSaatIni}',
      orElse: () => '',
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentClass = _studentClass(context);

      if (studentClass.isNotEmpty) {
        context.read<TimeTableBloc>().add(.fetchTimeTable(false, studentClass));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: const _TimeTableAppBar(),
      body: const _TimeTableBody(),
    );
  }
}

class _TimeTableAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TimeTableAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(toolbarHeight: 72, title: Text(l10n.timeTable));
  }

  @override
  Size get preferredSize => Size.fromHeight(72);
}

class _TimeTableBody extends StatefulWidget {
  const _TimeTableBody();

  @override
  State<_TimeTableBody> createState() => _TimeTableBodyState();
}

class _TimeTableBodyState extends State<_TimeTableBody> {
  String _selectedDay = TimeTableDaySelectorSection.defaultDayValues.first;

  String _studentClass(BuildContext context) {
    return context.read<UserBloc>().state.maybeWhen(
      success: (student) => '${student.kelasSaatIni}${student.noKelasSaatIni}',
      orElse: () => '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () {
        final studentClass = _studentClass(context);
        if (studentClass.isEmpty) return Future<void>.value();

        return blocRefresh<TimeTableBloc, TimeTableEvent, TimeTableState>(
          context: context,
          event: .fetchTimeTable(true, studentClass),
          isDone: (state) => state.maybeWhen(
            success: (_) => true,
            failure: (_) => true,
            orElse: () => false,
          ),
        );
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          TimeTableDaySelectorSection(
            selectedDay: _selectedDay,
            onSelected: (day) => setState(() => _selectedDay = day),
            sliver: SliverMainAxisGroup(
              slivers: [
                TimeTableScheduleGroupsSection(selectedDay: _selectedDay),
                SliverToBoxAdapter(child: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
