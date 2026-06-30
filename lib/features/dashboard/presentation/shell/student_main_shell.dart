// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/notifications/fcm_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app_configuration/presentation/bloc/app_configuration_bloc.dart';
import '../../../attendance/presentation/widgets/attendance_qr_bottom_sheet.dart';
import '../widgets/app_under_maintenance_container.dart';

class StudentMainShell extends StatelessWidget {
  const StudentMainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppConfigurationBloc>(
      create: (context) => di<AppConfigurationBloc>()
        ..add(
          const AppConfigurationEvent.appConfigurationRequested(
            forceRefresh: true,
          ),
        ),
      child: _StudentMainShellView(navigationShell: navigationShell),
    );
  }
}

class _StudentMainShellView extends StatefulWidget {
  const _StudentMainShellView({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<_StudentMainShellView> createState() => _StudentMainShellViewState();
}

class _StudentMainShellViewState extends State<_StudentMainShellView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activateNotifications().ignore();
    });
  }

  @override
  void dispose() {
    di<FCMService>().deactivateForUnauthenticatedUser().ignore();
    super.dispose();
  }

  Future<void> _activateNotifications() async {
    final fcmService = di<FCMService>();
    final shouldAskPermission = await fcmService
        .shouldAskNotificationPermission();

    if (!mounted) return;

    if (!shouldAskPermission) {
      fcmService
          .activateSilentlyForAuthenticatedUser(UserRole.student)
          .ignore();
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => const _NotificationPermissionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppConfigurationBloc, AppConfigurationState, bool>(
      selector: (state) => state.maybeWhen(
        success: (config) => config.appMaintenance,
        orElse: () => false,
      ),
      builder: (context, isUnderMaintenance) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          body: isUnderMaintenance
              ? const AppUnderMaintenanceContainer()
              : widget.navigationShell,
          floatingActionButton: isUnderMaintenance
              ? null
              : FloatingActionButton(
                  onPressed: () => showAttendanceQrSheet(context),
                  tooltip: AppLocalizations.of(context)!.attendanceQrCode,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.qr_code_2),
                ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: isUnderMaintenance
              ? null
              : _ShellBottomNavigationBar(
                  navigationShell: widget.navigationShell,
                ),
        );
      },
    );
  }
}

enum _NotificationPermissionSheetStatus {
  idle,
  loading,
  enabled,
  denied,
  failed,
}

class _NotificationPermissionBottomSheet extends StatefulWidget {
  const _NotificationPermissionBottomSheet();

  @override
  State<_NotificationPermissionBottomSheet> createState() =>
      _NotificationPermissionBottomSheetState();
}

class _NotificationPermissionBottomSheetState
    extends State<_NotificationPermissionBottomSheet> {
  _NotificationPermissionSheetStatus _status =
      _NotificationPermissionSheetStatus.idle;

  Future<void> _requestPermission() async {
    setState(() => _status = _NotificationPermissionSheetStatus.loading);

    final result = await di<FCMService>().activateForAuthenticatedUser(
      UserRole.student,
    );

    if (!mounted) return;

    setState(() {
      _status = switch (result) {
        FCMActivationResult.enabled =>
          _NotificationPermissionSheetStatus.enabled,
        FCMActivationResult.denied => _NotificationPermissionSheetStatus.denied,
        FCMActivationResult.failed => _NotificationPermissionSheetStatus.failed,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isLoading = _status == _NotificationPermissionSheetStatus.loading;

    final content = switch (_status) {
      _NotificationPermissionSheetStatus.idle => (
        icon: Icons.notifications_active_outlined,
        title: l10n.notificationPermissionTitle,
        description: l10n.notificationPermissionDesc,
        buttonLabel: l10n.enableNotifications,
      ),
      _NotificationPermissionSheetStatus.loading => (
        icon: Icons.notifications_outlined,
        title: l10n.notificationPermissionLoadingTitle,
        description: l10n.notificationPermissionLoadingDesc,
        buttonLabel: l10n.enableNotifications,
      ),
      _NotificationPermissionSheetStatus.enabled => (
        icon: Icons.notifications_active,
        title: l10n.notificationPermissionEnabledTitle,
        description: l10n.notificationPermissionEnabledDesc,
        buttonLabel: l10n.close,
      ),
      _NotificationPermissionSheetStatus.denied => (
        icon: Icons.notifications_off_outlined,
        title: l10n.notificationPermissionDeniedTitle,
        description: l10n.notificationPermissionDeniedDesc,
        buttonLabel: l10n.close,
      ),
      _NotificationPermissionSheetStatus.failed => (
        icon: Icons.error_outline,
        title: l10n.notificationPermissionFailedTitle,
        description: l10n.notificationPermissionFailedDesc,
        buttonLabel: l10n.tryAgain,
      ),
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(content.icon, size: 48, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              content.title,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              content.description,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: isLoading
                  ? null
                  : switch (_status) {
                      _NotificationPermissionSheetStatus.idle ||
                      _NotificationPermissionSheetStatus.failed =>
                        _requestPermission,
                      _ => () => Navigator.of(context).pop(),
                    },
              icon: isLoading
                  ? SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onSurface.withValues(alpha: 0.38),
                      ),
                    )
                  : Icon(
                      _status == _NotificationPermissionSheetStatus.enabled
                          ? Icons.check
                          : Icons.notifications_active_outlined,
                    ),
              label: Text(content.buttonLabel),
            ),
            if (_status == _NotificationPermissionSheetStatus.idle) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: Text(l10n.notNow),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShellBottomNavigationBar extends StatelessWidget {
  const _ShellBottomNavigationBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTabTapped(BuildContext context, int index) {
    if (index == 1) {
      showAttendanceQrSheet(context);
      return;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final selectedIndex = navigationShell.currentIndex == 1
        ? 0
        : navigationShell.currentIndex;

    return NavigationBar(
      backgroundColor: colorScheme.surfaceContainerLow,
      height: 85,
      elevation: 0,
      indicatorColor: colorScheme.secondaryContainer,
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _onTabTapped(context, index),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSecondaryContainer,
          );
        }
        return TextStyle(
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
        );
      }),
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.house_outlined, color: colorScheme.onSurfaceVariant),
          selectedIcon: Icon(
            Icons.house,
            color: colorScheme.onSecondaryContainer,
          ),
          label: l10n.home,
        ),
        NavigationDestination(
          icon: const SizedBox.square(dimension: 32),
          selectedIcon: const SizedBox.square(dimension: 32),
          label: l10n.qrCode,
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant),
          selectedIcon: Icon(
            Icons.person,
            color: colorScheme.onSecondaryContainer,
          ),
          label: l10n.profile,
        ),
      ],
    );
  }
}
