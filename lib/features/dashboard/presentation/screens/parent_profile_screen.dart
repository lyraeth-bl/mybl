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
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/logout_button.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../../../user/domain/entities/child_entity/child_entity.dart';
import '../../../user/domain/entities/parent_entity/parent_entity.dart';
import '../../../user/presentation/bloc/parent_bloc/parent_bloc.dart';
import '../widgets/parent_profile_children_section.dart';
import '../widgets/parent_profile_loading_section.dart';
import '../widgets/parent_profile_overview_section.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => di<AuthBloc>(),
      child: const _ParentProfileScreenView(),
    );
  }
}

class _ParentProfileScreenView extends StatelessWidget {
  const _ParentProfileScreenView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          successLogout: () =>
              context.read<SessionBloc>().add(const .loggedOut()),
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        appBar: AppTopBar(
          title: Text(l10n.profile),
          actions: [
            IconButton(
              onPressed: () => context.push(RouteNames.settings),
              tooltip: l10n.settings,
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: BlocBuilder<ParentBloc, ParentState>(
          builder: (context, parentState) {
            return parentState.maybeWhen(
              failure: (_) => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  AppEmptyStateSliver(
                    icon: Icons.face_retouching_off,
                    title: l10n.profileLoadFailedTitle,
                    message: l10n.profileLoadFailedSubtitle,
                    retryLabel: l10n.tryAgain,
                    onRetry: () => context.read<ParentBloc>().add(
                      const .started(forceRefresh: true),
                    ),
                  ),
                ],
              ),
              ready: (parent, children, selectedChild) =>
                  _ParentProfileReadyBody(
                    children: children,
                    selectedChild: selectedChild,
                    overview: parent,
                  ),
              orElse: () => const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [ParentProfileLoadingSection()],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ParentProfileReadyBody extends StatelessWidget {
  const _ParentProfileReadyBody({
    required this.overview,
    required this.children,
    required this.selectedChild,
  });

  final ParentEntity overview;
  final List<ChildEntity> children;
  final ChildEntity? selectedChild;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        final previousLoading = previous.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        final currentLoading = current.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return previousLoading != currentLoading;
      },
      builder: (context, authState) {
        final isLogoutLoading = authState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return RefreshWrapper(
          onRefresh: () => blocRefresh<ParentBloc, ParentEvent, ParentState>(
            context: context,
            event: const .started(forceRefresh: true),
            isDone: (state) => state.maybeWhen(
              ready: (_, _, _) => true,
              failure: (_) => true,
              orElse: () => false,
            ),
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              ParentProfileOverviewSection(parent: overview),
              ParentProfileChildrenSection(
                children: children,
                selectedChild: selectedChild,
                onChildSelected: (child) {
                  context.read<ParentBloc>().add(.childSelected(child));
                  AppToast.show(
                    context,
                    l10n.parentProfileSwitchChildSuccess(
                      child.nama.capitalizeEveryWord,
                    ),
                    type: .success,
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const .all(16),
                  child: LogoutButton(
                    onPressed: () =>
                        context.read<AuthBloc>().add(const .logoutRequested()),
                    isLoading: isLogoutLoading,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
