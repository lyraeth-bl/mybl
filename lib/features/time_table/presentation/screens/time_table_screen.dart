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
        context.read<TimeTableBloc>().add(
          TimeTableEvent.fetchTimeTable(false, studentClass),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

    return AppTopBar(
      toolbarHeight: 72,
      title: Text(l10n.timeTable),
      centerTitle: true,
      actions: const <Widget>[_TimeTableProfileAction()],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class _TimeTableProfileAction extends StatelessWidget {
  const _TimeTableProfileAction();

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
          event: TimeTableEvent.fetchTimeTable(true, studentClass),
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
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
