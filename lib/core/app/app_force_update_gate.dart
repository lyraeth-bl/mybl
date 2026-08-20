// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../features/app_configuration/domain/app_update_rules.dart';
import '../../features/app_configuration/presentation/bloc/app_configuration_bloc.dart';
import '../widgets/app_update_required_container.dart';

/// Replaces the app with an update notice when the installed build is older
/// than the one the backend requires.
///
/// Reads the configuration loaded by [AppMaintenanceGate] above it, so
/// maintenance takes precedence: during an outage there is nothing to update
/// into yet.
///
/// The gate stays out of the way until the installed version is known. A build
/// that blocked while reading its own version would flash the notice on every
/// cold start.
class AppForceUpdateGate extends StatefulWidget {
  const AppForceUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppForceUpdateGate> createState() => _AppForceUpdateGateState();
}

class _AppForceUpdateGateState extends State<AppForceUpdateGate> {
  String? _installedVersion;

  @override
  void initState() {
    super.initState();
    _readInstalledVersion();
  }

  Future<void> _readInstalledVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() => _installedVersion = packageInfo.version);
  }

  @override
  Widget build(BuildContext context) {
    final installedVersion = _installedVersion;

    if (installedVersion == null) return widget.child;

    return BlocSelector<
      AppConfigurationBloc,
      AppConfigurationState,
      ({bool mustUpdate, String? downloadLink})
    >(
      selector: (state) => state.maybeWhen(
        success: (config) {
          final isIOS = Platform.isIOS;

          return (
            mustUpdate:
                config.forceAppUpdate &&
                isAppUpdateRequired(
                  installedVersion: installedVersion,
                  requiredVersion: isIOS
                      ? config.iosAppVersion
                      : config.androidAppVersion,
                ),
            downloadLink: isIOS ? config.iosAppLink : config.androidAppLink,
          );
        },
        orElse: () => (mustUpdate: false, downloadLink: null),
      ),
      builder: (context, update) {
        if (!update.mustUpdate) return widget.child;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          body: AppUpdateRequiredContainer(downloadLink: update.downloadLink),
        );
      },
    );
  }
}
