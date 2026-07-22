// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/sarpras_summary/sarpras_summary.dart';
import '../bloc/sarpras_bloc.dart';
import '../widgets/sarpras_list_item.dart';
import '../widgets/sarpras_summary_chips.dart';

/// Entry screen listing the student's facility-use requests.
class SarprasScreen extends StatelessWidget {
  const SarprasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SarprasBloc>(
      create: (_) => di<SarprasBloc>(),
      child: const _SarprasView(),
    );
  }
}

class _SarprasView extends StatefulWidget {
  const _SarprasView();

  @override
  State<_SarprasView> createState() => _SarprasViewState();
}

class _SarprasViewState extends State<_SarprasView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SarprasBloc>().add(const SarprasEvent.fetchSarpras());
    });
  }

  Future<void> _openNew() async {
    final bloc = context.read<SarprasBloc>();
    final changed = await context.push<bool>(RouteNames.sarprasNew);
    if (changed == true) bloc.add(const SarprasEvent.fetchSarpras());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppTopBar(toolbarHeight: 72, title: Text(l10n.izinSarpras)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNew,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.sarprasSubmitAction),
      ),
      body: const _SarprasBody(),
    );
  }
}

class _SarprasBody extends StatefulWidget {
  const _SarprasBody();

  @override
  State<_SarprasBody> createState() => _SarprasBodyState();
}

class _SarprasBodyState extends State<_SarprasBody> {
  SarprasFilter _filter = SarprasFilter.all;

  /// The summary carried by [state], or null when the state carries none.
  ///
  /// Only `success` and `empty` carry a [SarprasSummary]; chips must be
  /// hidden for every other state, so this is the single source of truth
  /// for that decision.
  static SarprasSummary? _summaryOf(SarprasState state) => state.maybeWhen(
    success: (summary, _) => summary,
    empty: (summary) => summary,
    orElse: () => null,
  );

  Future<void> _openDetail(BuildContext context, int id) async {
    final bloc = context.read<SarprasBloc>();
    final changed = await context.push<bool>('/sarpras/$id');
    if (changed == true) bloc.add(const SarprasEvent.fetchSarpras());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshWrapper(
      onRefresh: () => blocRefresh<SarprasBloc, SarprasEvent, SarprasState>(
        context: context,
        event: const SarprasEvent.fetchSarpras(),
        isDone: (state) => state.maybeWhen(
          success: (_, _) => true,
          empty: (_) => true,
          failure: (_) => true,
          orElse: () => false,
        ),
      ),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          BlocBuilder<SarprasBloc, SarprasState>(
            builder: (context, state) {
              final summary = _summaryOf(state);

              return summary == null
                  ? SliverToBoxAdapter(child: 0.h)
                  : SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SarprasSummaryChips(
                          summary: summary,
                          selected: _filter,
                          onSelected: (value) =>
                              setState(() => _filter = value),
                        ),
                      ),
                    );
            },
            buildWhen: (previous, current) => previous != current,
          ),
          BlocBuilder<SarprasBloc, SarprasState>(
            builder: (context, state) => state.maybeWhen(
              failure: (_) => AppEmptyStateSliver(
                icon: Icons.error_outline_rounded,
                title: l10n.sarprasLoadFailedTitle,
                message: l10n.sarprasLoadFailedMessage,
                retryLabel: l10n.sarprasRetry,
                onRetry: () => context.read<SarprasBloc>().add(
                  const SarprasEvent.fetchSarpras(),
                ),
              ),
              empty: (_) => AppSliverGroup(
                title: l10n.sarprasHistory,
                sliver: AppEmptyStateSliver(
                  icon: Icons.inbox_rounded,
                  title: l10n.sarprasEmptyTitle,
                  message: l10n.sarprasEmptyMessage,
                ),
              ),
              success: (_, listSarpras) {
                final visible = listSarpras
                    .where((item) => _filter.matches(item.status))
                    .toList();

                return AppSliverGroup(
                  title: l10n.sarprasHistory,
                  sliver: visible.isEmpty
                      ? AppEmptyStateSliver(
                          icon: Icons.filter_alt_off_rounded,
                          title: l10n.sarprasFilterEmptyTitle,
                          message: l10n.sarprasFilterEmptyMessage,
                        )
                      : SliverList.builder(
                          itemCount: visible.length,
                          itemBuilder: (context, index) => SarprasListItem(
                            sarpras: visible[index],
                            onTap: () =>
                                _openDetail(context, visible[index].id),
                          ),
                        ),
                );
              },
              orElse: () => AppSliverGroup(
                title: l10n.sarprasHistory,
                sliver: SliverList.builder(
                  itemCount: 4,
                  itemBuilder: (context, _) => const _SarprasListItemSkeleton(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: 96.h),
        ],
      ),
    );
  }
}

class _SarprasListItemSkeleton extends StatelessWidget {
  const _SarprasListItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
      ).toShimmer(context, isLoading: true),
    );
  }
}
