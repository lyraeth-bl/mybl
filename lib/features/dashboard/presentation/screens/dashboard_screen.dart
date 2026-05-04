// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) =>
              di<UserBloc>()..add(const UserEvent.fetchStudentRequested()),
        ),

        BlocProvider<AuthBloc>(create: (context) => di<AuthBloc>()),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          successLogout: () =>
              context.read<SessionBloc>().add(const SessionEvent.loggedOut()),
        );
      },
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<SessionBloc, SessionState>(
                builder: (context, state) => state.maybeWhen(
                  authenticated: (accessToken) => Text(accessToken),
                  orElse: () => Text("Tidak ada token"),
                ),
              ),

              const SizedBox(height: 48),

              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) => state.maybeWhen(
                  success: (student) => Text("Nama : ${student.nama}"),
                  orElse: () => Text("Tidak ada data user"),
                ),
              ),

              const SizedBox(height: 48),

              FilledButton.icon(
                style: FilledButton.styleFrom(
                  foregroundColor: colorScheme.onErrorContainer,
                  backgroundColor: colorScheme.errorContainer,
                ),
                onPressed: () => context.read<AuthBloc>().add(
                  const AuthEvent.logoutRequested(),
                ),
                label: Text("Logout"),
                icon: Icon(Icons.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
