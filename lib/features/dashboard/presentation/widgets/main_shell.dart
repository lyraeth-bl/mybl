// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/notifications/fcm_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app_configuration/presentation/bloc/app_configuration_bloc.dart';
import 'app_under_maintenance_container.dart';
import 'menu_sheet_item.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

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
      child: _MainShellView(navigationShell: navigationShell),
    );
  }
}

class _MainShellView extends StatefulWidget {
  const _MainShellView({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<_MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<_MainShellView> {
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
      fcmService.activateSilentlyForAuthenticatedUser().ignore();
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
          bottomNavigationBar: isUnderMaintenance
              ? null
              : _MenuNavigationBar(navigationShell: widget.navigationShell),
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

    final result = await di<FCMService>().activateForAuthenticatedUser();

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

class _MenuNavigationBar extends StatefulWidget {
  const _MenuNavigationBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<_MenuNavigationBar> createState() => _MenuNavigationBarState();
}

class _MenuNavigationBarState extends State<_MenuNavigationBar> {
  bool _isMenuSheetOpen = false;

  List<MenuSheetItem> menuItems = MenuSheetItem.menuItems;

  void _onTabTapped(int index) {
    if (index == 1) {
      _openSheetMenu();
      return;
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _openSheetMenu() async {
    setState(() => _isMenuSheetOpen = true);

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _MenuBottomSheet(
        items: menuItems,
        onItemTap: (item) {
          Navigator.of(context).pop();

          context.push(item.routePath);
        },
      ),
    );

    if (mounted) setState(() => _isMenuSheetOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final customSelectedIndex = _isMenuSheetOpen
        ? 1
        : widget.navigationShell.currentIndex;

    return NavigationBar(
      backgroundColor: colorScheme.surface,
      height: 85,
      elevation: 0,
      indicatorColor: colorScheme.secondaryContainer,
      selectedIndex: customSelectedIndex,
      onDestinationSelected: (index) => _onTabTapped(index),
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
          icon: Icon(
            Icons.grid_view_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          selectedIcon: Icon(
            Icons.grid_view,
            color: colorScheme.onSecondaryContainer,
          ),
          label: l10n.menu,
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

class _MenuBottomSheet extends StatelessWidget {
  const _MenuBottomSheet({required this.items, required this.onItemTap});

  final List<MenuSheetItem> items;
  final void Function(MenuSheetItem item) onItemTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final isItemsEmpty = items.isEmpty;

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.80,
      builder: (context, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: isItemsEmpty
                  ? const EdgeInsetsGeometry.fromLTRB(20, 0, 20, 0)
                  : const EdgeInsetsGeometry.fromLTRB(20, 0, 20, 20),
              child: Text(
                l10n.menu,
                style: textTheme.titleLarge!.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: isItemsEmpty
                  ? Center(
                      child: Text(
                        l10n.emptyMenu,
                        style: textTheme.titleMedium!.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final label = item.resolveLabel(
                          AppLocalizations.of(context)!,
                        );
                        return _MenuGridItem(
                          item: item,
                          label: label,
                          onTap: () => onItemTap(item),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuGridItem extends StatelessWidget {
  const _MenuGridItem({
    required this.item,
    required this.onTap,
    required this.label,
  });

  final MenuSheetItem item;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Material(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(24),

          clipBehavior: Clip.antiAlias,

          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              child: Icon(
                item.icon,
                size: 32,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
