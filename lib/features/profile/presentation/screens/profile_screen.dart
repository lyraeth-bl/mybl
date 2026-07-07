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
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../widgets/profile_loading_section.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_overview_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => di<AuthBloc>(),
      child: const _ProfileScreenView(),
    );
  }
}

class _ProfileScreenView extends StatelessWidget {
  const _ProfileScreenView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          successLogout: () =>
              context.read<SessionBloc>().add(const SessionEvent.loggedOut()),
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        appBar: AppTopBar(
          toolbarHeight: 72,
          title: Text(l10n.profile),
          actions: [
            IconButton(
              onPressed: () => context.push(RouteNames.settings),
              tooltip: l10n.settings,
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            final isLoading = userState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );
            final student = userState.maybeWhen(
              success: (student) => student,
              orElse: () => null,
            );

            if (isLoading) {
              return const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [ProfileLoadingSection()],
              );
            }

            if (student == null) {
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  AppEmptyStateSliver(
                    icon: Icons.face_retouching_off,
                    title: l10n.profileLoadFailedTitle,
                    message: l10n.profileLoadFailedSubtitle,
                    retryLabel: l10n.tryAgain,
                    onRetry: () => context.read<UserBloc>().add(
                      const UserEvent.fetchStudentRequested(true),
                    ),
                  ),
                ],
              );
            }

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
                  onRefresh: () => blocRefresh<UserBloc, UserEvent, UserState>(
                    context: context,
                    event: const UserEvent.fetchStudentRequested(true),
                    isDone: (state) => state.maybeWhen(
                      success: (_) => true,
                      failure: (_) => true,
                      orElse: () => false,
                    ),
                  ),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      ProfileOverviewSection(student: student),
                      ProfileMenuSection(
                        isLogoutLoading: isLogoutLoading,
                        onPersonalInfoTap: () =>
                            context.push(RouteNames.profileDetail),
                        onLogoutPressed: () => context.read<AuthBloc>().add(
                          const AuthEvent.logoutRequested(),
                        ),
                      ),
                      SliverToBoxAdapter(child: 48.h),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
