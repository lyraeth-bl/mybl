// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/presentation/bloc/parent_daily_attendance_bloc/parent_daily_attendance_bloc.dart';
import '../../../user/domain/entities/child_entity/child_entity.dart';
import '../../../user/presentation/bloc/parent_bloc/parent_bloc.dart';
import '../widgets/parent_dashboard_daily_attendance_section.dart';
import '../widgets/parent_dashboard_profile_section.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ParentDailyAttendanceBloc>(
      create: (_) => di<ParentDailyAttendanceBloc>(),
      child: const _ParentDashboardView(),
    );
  }
}

class _ParentDashboardView extends StatefulWidget {
  const _ParentDashboardView();

  @override
  State<_ParentDashboardView> createState() => _ParentDashboardViewState();
}

class _ParentDashboardViewState extends State<_ParentDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParentDailyAttendanceBloc>().add(
        const ParentDailyAttendanceEvent.dailyAttendanceRequested(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ParentBloc, ParentState>(
      builder: (context, state) {
        final record = state.maybeWhen(
          ready: (parent, children, selectedChild) => (
            nama: parent.nama,
            child: selectedChild,
            hasMultipleChildren: children.length > 1,
            children: children,
          ),
          orElse: () => (
            nama: '',
            child: null,
            hasMultipleChildren: false,
            children: <ChildEntity>[],
          ),
        );
        final isLoading = state.maybeWhen(
          initial: () => true,
          loading: () => true,
          orElse: () => false,
        );

        return Scaffold(
          appBar: const _ParentDashboardAppTopBar(),
          backgroundColor: colorScheme.surfaceContainer,
          body: _ParentDashboardBody(
            children: record.children,
            isLoading: isLoading,
          ),
        );
      },
    );
  }
}

class _ParentDashboardAppTopBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ParentDashboardAppTopBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(
      backgroundColor: colorScheme.surfaceContainerLow,
      toolbarHeight: 72,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _WavingHands(colorScheme: colorScheme),
              _GreetingAndName(
                colorScheme: colorScheme,
                l10n: l10n,
                textTheme: textTheme,
              ),
            ].separatedBy(8.w),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _ParentDashboardBody extends StatelessWidget {
  const _ParentDashboardBody({this.children, required this.isLoading});

  final List<ChildEntity>? children;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () => Future.wait([
        blocRefresh<ParentBloc, ParentEvent, ParentState>(
          context: context,
          event: const ParentEvent.started(forceRefresh: true),
          isDone: (state) => state.maybeWhen(
            ready: (_, _, _) => true,
            failure: (_) => true,
            orElse: () => false,
          ),
        ),
        blocRefresh<
          ParentDailyAttendanceBloc,
          ParentDailyAttendanceEvent,
          ParentDailyAttendanceState
        >(
          context: context,
          event: const ParentDailyAttendanceEvent.dailyAttendanceRequested(
            forceRefresh: true,
          ),
          isDone: (state) => state.maybeWhen(
            success: (_) => true,
            emptyAttendance: () => true,
            failure: (_) => true,
            orElse: () => false,
          ),
        ),
      ]),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          ParentDashboardProfileSection(
            children: children,
            isLoading: isLoading,
          ),
          const ParentDashboardDailyAttendanceSection(),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}

class _WavingHands extends StatelessWidget {
  const _WavingHands({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final icon = Icon(Icons.waving_hand, color: colorScheme.onSurface);
    if (disableAnimations) return icon;
    return icon
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .rotate(begin: -0.1, end: 0.05, duration: 3.seconds);
  }
}

class _GreetingAndName extends StatelessWidget {
  const _GreetingAndName({
    required this.colorScheme,
    required this.l10n,
    required this.textTheme,
  });

  final AppLocalizations l10n;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 11) return l10n.goodMorning;
    if (hour < 15) return l10n.goodAfternoon;
    if (hour < 18) return l10n.goodEvening;
    return l10n.goodNight;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(l10n),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          BlocSelector<
            ParentBloc,
            ParentState,
            ({String name, bool isLoading})
          >(
            selector: (state) => state.maybeWhen(
              ready: (parent, _, _) => (name: parent.nama, isLoading: false),
              orElse: () => (name: '', isLoading: true),
            ),
            builder: (context, data) {
              if (data.isLoading) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const SizedBox(width: 140, height: 20),
                ).toShimmer(context, isLoading: true);
              }

              return Text(
                l10n.parentGreetingName(data.name.capitalizeEveryWord),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              );
            },
          ),
        ].separatedBy(4.h),
      ),
    );
  }
}
