// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_overview_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => di<AuthBloc>()),
        BlocProvider<NotificationBloc>(
          create: (context) => di<NotificationBloc>(),
        ),
      ],
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
        appBar: AppTopBar(
          toolbarHeight: 72,
          title: Text(l10n.profile),
          centerTitle: true,
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            final student = userState.maybeWhen(
              success: (student) => student,
              orElse: () => null,
            );

            if (student == null) {
              return const Center(child: CircularProgressIndicator());
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

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
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
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
