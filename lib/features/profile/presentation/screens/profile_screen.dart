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
import '../../../academic_result/presentation/bloc/academic_result_bloc.dart';
import '../../../attendance/presentation/bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../discipline/presentation/bloc/merit_bloc/merit_bloc.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_overview_section.dart';
import '../widgets/profile_summary_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => di<AuthBloc>()),
        BlocProvider<MeritBloc>(create: (context) => di<MeritBloc>()),
        BlocProvider<MonthlyAttendanceBloc>(
          create: (context) => di<MonthlyAttendanceBloc>(),
        ),
        BlocProvider<AcademicResultBloc>(
          create: (context) => di<AcademicResultBloc>(),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => di<NotificationBloc>(),
        ),
      ],
      child: const _ProfileScreenView(),
    );
  }
}

class _ProfileScreenView extends StatefulWidget {
  const _ProfileScreenView();

  @override
  State<_ProfileScreenView> createState() => _ProfileScreenViewState();
}

class _ProfileScreenViewState extends State<_ProfileScreenView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();

      context.read<MeritBloc>().add(const MeritEvent.fetchMerit());
      context.read<MonthlyAttendanceBloc>().add(
        MonthlyAttendanceEvent.monthChangeRequested(
          month: now.month,
          year: now.year,
        ),
      );
      context.read<AcademicResultBloc>().add(
        const AcademicResultEvent.fetchAcademicResult(),
      );
    });
  }

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
          actions: [
            IconButton(
              onPressed: () => context.push(RouteNames.settings),
              tooltip: l10n.settings,
              icon: const Icon(Icons.settings_rounded),
            ),
          ],
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
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    ProfileOverviewSection(student: student),
                    const ProfileSummarySection(),
                    ProfileMenuSection(
                      isLogoutLoading: isLogoutLoading,
                      onPersonalInfoTap: () =>
                          context.push(RouteNames.profileDetail),
                      onLogoutPressed: () => context.read<AuthBloc>().add(
                        const AuthEvent.logoutRequested(),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 48)),
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
