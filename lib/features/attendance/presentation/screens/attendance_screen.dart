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
import '../bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';
import '../widgets/attendance_calendar_section.dart';
import '../widgets/attendance_chart_section.dart';
import '../widgets/attendance_filtered_section.dart';
import '../widgets/attendance_summary_section.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MonthlyAttendanceBloc>(
      create: (context) => di<MonthlyAttendanceBloc>(),
      child: const _AttendanceScreenView(),
    );
  }
}

class _AttendanceScreenView extends StatefulWidget {
  const _AttendanceScreenView();

  @override
  State<_AttendanceScreenView> createState() => _AttendanceScreenViewState();
}

class _AttendanceScreenViewState extends State<_AttendanceScreenView> {
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MonthlyAttendanceBloc>().add(
        MonthlyAttendanceEvent.monthChangeRequested(
          month: now.month,
          year: now.year,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _AttendanceAppBar(),
      body: const _AttendanceBody(),
    );
  }
}

@immutable
class _AttendanceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AttendanceAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(
      toolbarHeight: 72,
      title: Text(l10n.dailyAttendance),
      centerTitle: true,
      actions: const <Widget>[_AttendanceProfileAction()],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class _AttendanceProfileAction extends StatelessWidget {
  const _AttendanceProfileAction();

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

class _AttendanceRefreshWrapper extends StatelessWidget {
  const _AttendanceRefreshWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () {
        final state = context.read<MonthlyAttendanceBloc>().state;

        final month = state.maybeWhen(
          success: (m, _, _, _, _, _) => m,
          loading: (m, _) => m,
          orElse: () => DateTime.now().month,
        );
        final year = state.maybeWhen(
          success: (_, y, _, _, _, _) => y,
          loading: (_, y) => y,
          orElse: () => DateTime.now().year,
        );

        return blocRefresh<
          MonthlyAttendanceBloc,
          MonthlyAttendanceEvent,
          MonthlyAttendanceState
        >(
          context: context,
          event: MonthlyAttendanceEvent.monthChangeRequested(
            month: month,
            year: year,
            forceRefresh: true,
          ),
          isDone: (state) => state.maybeWhen(
            success: (_, _, _, _, _, _) => true,
            failure: (_) => true,
            orElse: () => false,
          ),
        );
      },
      child: child,
    );
  }
}

class _AttendanceBody extends StatelessWidget {
  const _AttendanceBody();

  @override
  Widget build(BuildContext context) {
    return _AttendanceRefreshWrapper(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: const [
          AttendanceSummarySection(),
          AttendanceCalendarSection(),
          AttendanceFilteredSection(),
          AttendanceChartSection(),
          SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
