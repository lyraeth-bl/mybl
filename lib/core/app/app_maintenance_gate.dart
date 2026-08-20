// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/app_configuration/presentation/bloc/app_configuration_bloc.dart';
import '../../features/sessions/presentation/bloc/session_bloc.dart';
import '../enums/user_role.dart';
import '../widgets/app_under_maintenance_container.dart';

/// Fetches the app configuration and replaces the whole app with the
/// maintenance notice while the backend reports maintenance mode.
///
/// Sits above the router so every route is covered — the shells only wrap the
/// dashboard and profile branches, leaving the rest reachable through
/// notification deep links.
///
/// Owning the fetch here matters as much as owning the gate: while the request
/// lived in the shells, a cold start straight into a non-shell route never
/// asked for the config, so maintenance mode stayed invisible on exactly the
/// routes the gate was meant to cover.
///
/// The gate deliberately runs before sign-in too. An outage that stops people
/// logging in is the case where the notice matters most, and the config
/// endpoint is public, so a signed-out user can both read the flag and clear it
/// by retrying.
class AppMaintenanceGate extends StatefulWidget {
  const AppMaintenanceGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppMaintenanceGate> createState() => _AppMaintenanceGateState();
}

class _AppMaintenanceGateState extends State<AppMaintenanceGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _requestConfiguration(),
    );
  }

  /// Requests the configuration for whoever is using the app right now.
  ///
  /// Without a session there is no role to read, so the student endpoint acts
  /// as the public default; signing in as a parent re-requests the parent one.
  void _requestConfiguration() {
    if (!mounted) return;

    final role = context.read<SessionBloc>().state.maybeWhen(
      authenticated: (_, role) => role,
      orElse: () => UserRole.student,
    );

    context.read<AppConfigurationBloc>().add(
      AppConfigurationEvent.appConfigurationRequested(
        role: role,
        forceRefresh: true,
      ),
    );
  }

  static bool _isAuthenticated(SessionState state) =>
      state.maybeWhen(authenticated: (_, _) => true, orElse: () => false);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listenWhen: (previous, current) =>
          _isAuthenticated(previous) != _isAuthenticated(current),
      listener: (context, state) => _requestConfiguration(),
      child: BlocSelector<AppConfigurationBloc, AppConfigurationState, bool>(
        selector: (state) => state.maybeWhen(
          success: (config) => config.appMaintenance,
          orElse: () => false,
        ),
        builder: (context, isUnderMaintenance) {
          if (!isUnderMaintenance) return widget.child;

          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            body: const AppUnderMaintenanceContainer(),
          );
        },
      ),
    );
  }
}
