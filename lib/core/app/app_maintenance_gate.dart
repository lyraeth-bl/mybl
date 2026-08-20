// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/app_configuration/presentation/bloc/app_configuration_bloc.dart';
import '../../features/sessions/presentation/bloc/session_bloc.dart';
import '../widgets/app_under_maintenance_container.dart';

/// Fetches the app configuration for the active session and replaces the whole
/// app with the maintenance notice while the backend reports maintenance mode.
///
/// Sits above the router so every route is covered — the shells only wrap the
/// dashboard and profile branches, leaving the rest reachable through
/// notification deep links.
///
/// Owning the fetch here matters as much as owning the gate: while the request
/// lived in the shells, a cold start straight into a non-shell route never
/// asked for the config, so maintenance mode stayed invisible on exactly the
/// routes the gate was added to cover.
///
/// Only gates an authenticated session. The config endpoint requires a token,
/// so a signed-out user can neither fetch the flag nor clear it by retrying.
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

  void _requestConfiguration() {
    if (!mounted) return;

    final role = context.read<SessionBloc>().state.maybeWhen(
      authenticated: (_, role) => role,
      orElse: () => null,
    );

    if (role == null) return;

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
      child: BlocSelector<SessionBloc, SessionState, bool>(
        selector: _isAuthenticated,
        builder: (context, isAuthenticated) {
          if (!isAuthenticated) return widget.child;

          return BlocSelector<
            AppConfigurationBloc,
            AppConfigurationState,
            bool
          >(
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
          );
        },
      ),
    );
  }
}
