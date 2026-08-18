// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/extracurricular_attendance_bloc.dart';
import '../bloc/extracurricular_bloc.dart';
import '../widgets/extracurricular_attendance_content.dart';
import '../widgets/extracurricular_content.dart';
import '../widgets/extracurricular_state_widgets.dart';

class ExtracurricularScreen extends StatelessWidget {
  const ExtracurricularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExtracurricularBloc>(
          create: (context) => di<ExtracurricularBloc>(),
        ),
        BlocProvider<ExtracurricularAttendanceBloc>(
          create: (context) => di<ExtracurricularAttendanceBloc>(),
        ),
      ],
      child: const _ExtracurricularView(),
    );
  }
}

class _ExtracurricularView extends StatefulWidget {
  const _ExtracurricularView();

  @override
  State<_ExtracurricularView> createState() => _ExtracurricularViewState();
}

class _ExtracurricularViewState extends State<_ExtracurricularView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExtracurricularBloc>().add(const .fetchExtracurricular());
      context.read<ExtracurricularAttendanceBloc>().add(
        const .fetchExtracurricularAttendances(),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppTopBar(
        toolbarHeight: 72,
        title: Text(l10n.extracurricular),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.score),
            Tab(text: l10n.attendance),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ExtracurricularTab(),
          _ExtracurricularAttendanceTab(),
        ],
      ),
    );
  }
}

class _ExtracurricularTab extends StatelessWidget {
  const _ExtracurricularTab();

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () =>
          blocRefresh<
            ExtracurricularBloc,
            ExtracurricularEvent,
            ExtracurricularState
          >(
            context: context,
            event: const .fetchExtracurricular(true),
            isDone: (state) => state.maybeWhen(
              success: (_) => true,
              failure: (_) => true,
              orElse: () => false,
            ),
          ),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          BlocBuilder<ExtracurricularBloc, ExtracurricularState>(
            builder: (context, state) {
              return state.maybeWhen(
                success: (extracurricular) =>
                    ExtracurricularContent(extracurricular: extracurricular),
                failure: (failure) => AppEmptyStateSliver(
                  icon: Icons.error_outline_rounded,
                  message: failure.localizedMessage(
                    AppLocalizations.of(context)!,
                  ),
                  retryLabel: AppLocalizations.of(context)!.tryAgain,
                  onRetry: () => context.read<ExtracurricularBloc>().add(
                    const .fetchExtracurricular(true),
                  ),
                ),
                orElse: () => const ExtracurricularLoadingContent(),
              );
            },
          ),
          SliverToBoxAdapter(child: 24.h),
        ],
      ),
    );
  }
}

class _ExtracurricularAttendanceTab extends StatelessWidget {
  const _ExtracurricularAttendanceTab();

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () =>
          blocRefresh<
            ExtracurricularAttendanceBloc,
            ExtracurricularAttendanceEvent,
            ExtracurricularAttendanceState
          >(
            context: context,
            event: const .fetchExtracurricularAttendances(),
            isDone: (state) => state.maybeWhen(
              success: (_) => true,
              failure: (_) => true,
              orElse: () => false,
            ),
          ),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          BlocBuilder<
            ExtracurricularAttendanceBloc,
            ExtracurricularAttendanceState
          >(
            builder: (context, state) {
              return state.maybeWhen(
                success: (attendances) =>
                    ExtracurricularAttendanceContent(attendances: attendances),
                failure: (failure) => AppEmptyStateSliver(
                  icon: Icons.error_outline_rounded,
                  message: failure.localizedMessage(
                    AppLocalizations.of(context)!,
                  ),
                  retryLabel: AppLocalizations.of(context)!.tryAgain,
                  onRetry: () => context
                      .read<ExtracurricularAttendanceBloc>()
                      .add(const .fetchExtracurricularAttendances()),
                ),
                orElse: () => const ExtracurricularAttendanceLoadingContent(),
              );
            },
          ),
          SliverToBoxAdapter(child: 24.h),
        ],
      ),
    );
  }
}
