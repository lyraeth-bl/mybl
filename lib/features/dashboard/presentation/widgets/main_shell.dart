// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Card.outlined(
        child: NavigationBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          indicatorColor: colorScheme.primaryContainer,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => _onTabTapped(index),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.house_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.house,
                color: colorScheme.onPrimaryContainer,
              ),
              label: l10n.home,
            ),
            NavigationDestination(
              icon: Icon(
                Icons.space_dashboard_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.space_dashboard,
                color: colorScheme.onPrimaryContainer,
              ),
              label: l10n.dashboard,
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline,
                color: colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.person,
                color: colorScheme.onPrimaryContainer,
              ),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
