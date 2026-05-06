// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../app_configuration/presentation/bloc/app_configuration_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../widgets/app_under_maintenance_container.dart';
import '../widgets/dashboard_header.dart';

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
        BlocProvider<AppConfigurationBloc>(
          create: (context) =>
              di<AppConfigurationBloc>()
                ..add(const AppConfigurationEvent.appConfigurationRequested()),
        ),
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

    return BlocConsumer<AppConfigurationBloc, AppConfigurationState>(
      listener: (context, state) {
        state.whenOrNull(
          success: (appConfiguration) {
            // Handle buttomsheet untuk update app langsung dari app disini
            // ada pengecekan version dari DB dengan versi build terlebih dahulu dengan check
            // appConfiguration.androidAppVersion atau appConfiguration.iosAppLink
            // untuk sekarang bisa di abaikan dulu, fokus di pembuatan app maintenance container.
          },
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
            ),
          ),
          success: (appConfiguration) {
            if (appConfiguration.appMaintenance) {
              // Widget belum dibuat.
              return const AppUnderMaintenanceContainer();
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [SliverToBoxAdapter(child: const DashboardHeader())],
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
