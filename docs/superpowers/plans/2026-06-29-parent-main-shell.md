# Parent Main Shell Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `ParentMainShell` — a `StatefulShellRoute`-based shell with a 3-tab bottom nav (Home, Notifications, Profile) — so the parent user flow has persistent navigation.

**Architecture:** A new `StatefulShellRoute.indexedStack` sits alongside the student shell in `app_router.dart`. `ParentMainShell` wraps the shell with `AppConfigurationBloc`, notification-permission flow, and a 3-tab `NavigationBar`. The existing `ParentDashboardScreen` becomes branch 0; the shared `NotificationScreen` is branch 1; a new placeholder `ParentProfileScreen` is branch 2.

**Tech Stack:** Flutter 3.41.8, `go_router` (StatefulShellRoute), `flutter_bloc`, `get_it` (via `di<T>()`), `flutter_localizations` (l10n via `AppLocalizations.of(context)!`).

## Global Constraints

- Copyright header on every new Dart file: `// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved. // Use of this source code is governed by a MIT License // that can be found in the LICENSE file.`
- `Theme.of(context).colorScheme` / `Theme.of(context).textTheme` — no hard-coded colors or text styles.
- `AppLocalizations.of(context)!` for all visible text.
- Use `di<T>()` from `lib/core/di/get_it_constant.dart` to resolve services — never construct them directly.
- Lines ≤ 80 characters.

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `lib/core/app_router/route_names.dart` | Add `parentNotification` + `parentProfile` constants |
| Create | `lib/features/dashboard/presentation/screens/parent_profile_screen.dart` | Placeholder profile screen for parent |
| Create | `lib/features/dashboard/presentation/shell/parent_main_shell.dart` | Shell widget: BLoC injection, FCM flow, 3-tab bottom nav |
| Modify | `lib/core/app_router/app_router.dart` | Fix student shell import; add parent `StatefulShellRoute` |

---

### Task 1: Route Name Constants

**Files:**
- Modify: `lib/core/app_router/route_names.dart`

**Interfaces:**
- Produces: `RouteNames.parentNotification` (`"/parent/notification"`), `RouteNames.parentProfile` (`"/parent/profile"`) — used by Tasks 3 and 4.

- [ ] **Step 1: Add two constants inside `RouteNames`**

Open `lib/core/app_router/route_names.dart`. After the existing `parentDashboard` constant, add:

```dart
  // Parent Notification
  static const String parentNotification = "/parent/notification";

  // Parent Profile
  static const String parentProfile = "/parent/profile";
```

The block now looks like:

```dart
  // Parent Dashboard
  static const String parentDashboard = "/parent/dashboard";

  // Parent Notification
  static const String parentNotification = "/parent/notification";

  // Parent Profile
  static const String parentProfile = "/parent/profile";
```

- [ ] **Step 2: Verify no analysis errors**

```bash
flutter analyze lib/core/app_router/route_names.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/app_router/route_names.dart
git commit -m "feat(router): add parentNotification and parentProfile route name constants"
```

---

### Task 2: ParentProfileScreen Placeholder

**Files:**
- Create: `lib/features/dashboard/presentation/screens/parent_profile_screen.dart`
- Test: `test/features/dashboard/presentation/screens/parent_profile_screen_test.dart`

**Interfaces:**
- Produces: `class ParentProfileScreen extends StatelessWidget` with `const ParentProfileScreen({super.key})` — consumed by Task 4 (`app_router.dart`).

- [ ] **Step 1: Write the failing test**

Create `test/features/dashboard/presentation/screens/parent_profile_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/features/dashboard/presentation/screens/parent_profile_screen.dart';

void main() {
  testWidgets('ParentProfileScreen renders a Scaffold', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: ParentProfileScreen(),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test to confirm it fails**

```bash
flutter test test/features/dashboard/presentation/screens/parent_profile_screen_test.dart
```

Expected: compile error — `parent_profile_screen.dart` does not exist yet.

- [ ] **Step 3: Create the screen**

Create `lib/features/dashboard/presentation/screens/parent_profile_screen.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: Text(AppLocalizations.of(context)!.profile),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Center(
        child: Text(
          'Coming soon',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to confirm it passes**

```bash
flutter test test/features/dashboard/presentation/screens/parent_profile_screen_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Verify analysis**

```bash
flutter analyze lib/features/dashboard/presentation/screens/parent_profile_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/dashboard/presentation/screens/parent_profile_screen.dart \
        test/features/dashboard/presentation/screens/parent_profile_screen_test.dart
git commit -m "feat(parent): add ParentProfileScreen placeholder"
```

---

### Task 3: ParentMainShell Widget

**Files:**
- Create: `lib/features/dashboard/presentation/shell/parent_main_shell.dart`
- Test: `test/features/dashboard/presentation/shell/parent_main_shell_test.dart`

**Interfaces:**
- Consumes: `AppConfigurationBloc`, `FCMService` from DI (already registered in core — do not re-register); `AppUnderMaintenanceContainer` from `../widgets/app_under_maintenance_container.dart`. Note: tab switching uses `navigationShell.goBranch(index)` — route name constants are not used inside the shell widget.
- Produces: `class ParentMainShell extends StatelessWidget` with `const ParentMainShell({super.key, required this.navigationShell})` where `navigationShell` is `StatefulNavigationShell` from `go_router` — consumed by Task 4.

- [ ] **Step 1: Write the failing test**

Create `test/features/dashboard/presentation/shell/parent_main_shell_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/dashboard/presentation/shell/parent_main_shell.dart';

void main() {
  testWidgets(
    'parent bottom nav renders 3 NavigationDestinations',
    (tester) async {
      // Build a NavigationBar with 3 destinations in isolation —
      // avoids needing a real StatefulNavigationShell.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: NavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.house_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_outlined),
                  label: 'Notifications',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(NavigationDestination), findsNWidgets(3));
    },
  );
}
```

- [ ] **Step 2: Run the test to confirm it fails**

```bash
flutter test test/features/dashboard/presentation/shell/parent_main_shell_test.dart
```

Expected: compile error — `parent_main_shell.dart` does not exist yet.

- [ ] **Step 3: Create `parent_main_shell.dart`**

Create `lib/features/dashboard/presentation/shell/parent_main_shell.dart`:

```dart
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
import '../widgets/app_under_maintenance_container.dart';

class ParentMainShell extends StatelessWidget {
  const ParentMainShell({
    super.key,
    required this.navigationShell,
  });

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
      child: _ParentMainShellView(navigationShell: navigationShell),
    );
  }
}

class _ParentMainShellView extends StatefulWidget {
  const _ParentMainShellView({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<_ParentMainShellView> createState() =>
      _ParentMainShellViewState();
}

class _ParentMainShellViewState extends State<_ParentMainShellView> {
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
    final shouldAskPermission =
        await fcmService.shouldAskNotificationPermission();

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
      builder: (sheetContext) =>
          const _NotificationPermissionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppConfigurationBloc, AppConfigurationState,
        bool>(
      selector: (state) => state.maybeWhen(
        success: (config) => config.appMaintenance,
        orElse: () => false,
      ),
      builder: (context, isUnderMaintenance) {
        return Scaffold(
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainer,
          body: isUnderMaintenance
              ? const AppUnderMaintenanceContainer()
              : widget.navigationShell,
          bottomNavigationBar: isUnderMaintenance
              ? null
              : _ParentShellBottomNavigationBar(
                  navigationShell: widget.navigationShell,
                ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Notification permission bottom sheet (same flow as StudentMainShell)
// ---------------------------------------------------------------------------

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
    setState(
      () => _status = _NotificationPermissionSheetStatus.loading,
    );

    final result =
        await di<FCMService>().activateForAuthenticatedUser();

    if (!mounted) return;

    setState(() {
      _status = switch (result) {
        FCMActivationResult.enabled =>
          _NotificationPermissionSheetStatus.enabled,
        FCMActivationResult.denied =>
          _NotificationPermissionSheetStatus.denied,
        FCMActivationResult.failed =>
          _NotificationPermissionSheetStatus.failed,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isLoading =
        _status == _NotificationPermissionSheetStatus.loading;

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
                        color: colorScheme.onSurface
                            .withValues(alpha: 0.38),
                      ),
                    )
                  : Icon(
                      _status ==
                              _NotificationPermissionSheetStatus
                                  .enabled
                          ? Icons.check
                          : Icons.notifications_active_outlined,
                    ),
              label: Text(content.buttonLabel),
            ),
            if (_status ==
                _NotificationPermissionSheetStatus.idle) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed:
                    isLoading ? null : () => Navigator.of(context).pop(),
                child: Text(l10n.notNow),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom navigation bar
// ---------------------------------------------------------------------------

class _ParentShellBottomNavigationBar extends StatelessWidget {
  const _ParentShellBottomNavigationBar({
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return NavigationBar(
      backgroundColor: colorScheme.surfaceContainerLow,
      height: 85,
      elevation: 0,
      indicatorColor: colorScheme.secondaryContainer,
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
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
          icon: Icon(
            Icons.house_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          selectedIcon: Icon(
            Icons.house,
            color: colorScheme.onSecondaryContainer,
          ),
          label: l10n.home,
        ),
        NavigationDestination(
          icon: Icon(
            Icons.notifications_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          selectedIcon: Icon(
            Icons.notifications,
            color: colorScheme.onSecondaryContainer,
          ),
          label: l10n.notifications,
        ),
        NavigationDestination(
          icon: Icon(
            Icons.person_outline,
            color: colorScheme.onSurfaceVariant,
          ),
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
```

- [ ] **Step 4: Run the test to confirm it passes**

```bash
flutter test test/features/dashboard/presentation/shell/parent_main_shell_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Verify analysis**

```bash
flutter analyze lib/features/dashboard/presentation/shell/parent_main_shell.dart
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/dashboard/presentation/shell/parent_main_shell.dart \
        test/features/dashboard/presentation/shell/parent_main_shell_test.dart
git commit -m "feat(parent): add ParentMainShell with 3-tab bottom navigation"
```

---

### Task 4: Wire Up Router

**Files:**
- Modify: `lib/core/app_router/app_router.dart`

**Interfaces:**
- Consumes: `StudentMainShell` from `shell/student_main_shell.dart`; `ParentMainShell` from `shell/parent_main_shell.dart` (Task 3); `ParentProfileScreen` from `screens/parent_profile_screen.dart` (Task 2); `RouteNames.parentNotification`, `RouteNames.parentProfile` (Task 1).
- Produces: parent user flow routed through `StatefulShellRoute.indexedStack` with branches at `/parent/dashboard`, `/parent/notification`, `/parent/profile`.

- [ ] **Step 1: Fix the student shell import**

In `lib/core/app_router/app_router.dart`, replace the old import:

```dart
// Remove:
import '../../features/dashboard/presentation/widgets/main_shell.dart';

// Add:
import '../../features/dashboard/presentation/shell/student_main_shell.dart';
```

In the `StatefulShellRoute.indexedStack` builder for the student shell (near the bottom of the routes list), change `MainShell` → `StudentMainShell`:

```dart
// Before:
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      MainShell(navigationShell: navigationShell),

// After:
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      StudentMainShell(navigationShell: navigationShell),
```

- [ ] **Step 2: Add the new imports**

At the top of `app_router.dart`, add these two imports alongside the existing dashboard imports:

```dart
import '../../features/dashboard/presentation/shell/parent_main_shell.dart';
import '../../features/dashboard/presentation/screens/parent_profile_screen.dart';
```

- [ ] **Step 3: Replace the flat parent `GoRoute` with a `StatefulShellRoute`**

Find and remove the flat `GoRoute` for `/parent/dashboard`:

```dart
// Remove this entire GoRoute:
GoRoute(
  path: RouteNames.parentDashboard,
  builder: (context, state) => const ParentDashboardScreen(),
),
```

Add the parent `StatefulShellRoute` in its place (keep it in the same position in the routes list):

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      ParentMainShell(navigationShell: navigationShell),
  branches: <StatefulShellBranch>[
    StatefulShellBranch(
      routes: <GoRoute>[
        GoRoute(
          path: RouteNames.parentDashboard,
          builder: (context, state) =>
              const ParentDashboardScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: <GoRoute>[
        GoRoute(
          path: RouteNames.parentNotification,
          builder: (context, state) =>
              const NotificationScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: <GoRoute>[
        GoRoute(
          path: RouteNames.parentProfile,
          builder: (context, state) =>
              const ParentProfileScreen(),
        ),
      ],
    ),
  ],
),
```

- [ ] **Step 4: Verify analysis**

```bash
flutter analyze lib/core/app_router/app_router.dart
```

Expected: `No issues found!`

- [ ] **Step 5: Run the full app and manually verify**

```bash
flutter run
```

Log in as a parent user, select a child, then confirm:
1. App lands on `/parent/dashboard` (Home tab active).
2. Tapping the Notifications tab navigates to `NotificationScreen`.
3. Tapping the Profile tab navigates to `ParentProfileScreen` ("Coming soon").
4. Switching tabs preserves scroll/state in each branch.
5. Student login still works — `MainShell` → 3-tab student shell with QR FAB is unaffected.

- [ ] **Step 6: Commit**

```bash
git add lib/core/app_router/app_router.dart
git commit -m "feat(router): add parent StatefulShellRoute with Home/Notifications/Profile branches"
```
