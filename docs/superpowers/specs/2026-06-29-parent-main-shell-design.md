# Parent Main Shell — Design Spec

**Date:** 2026-06-29
**Branch:** feature/parent

---

## Overview

Add a `ParentMainShell` — a `StatefulShellRoute`-based shell with a 3-tab bottom navigation bar — for the parent user flow. This mirrors the existing `StudentMainShell` but is fully independent, with tabs appropriate for parent users (Home, Notifications, Profile).

---

## Motivation

Currently the parent flow lands on a flat `GoRoute` (`/parent/dashboard`) with no persistent navigation. As parent features grow, a shell is needed to support tab-based navigation with preserved state per branch — consistent with how the student flow works.

---

## Tabs

| Index | Label         | Route                   | Screen                  |
|-------|---------------|-------------------------|-------------------------|
| 0     | Home          | `/parent/dashboard`     | `ParentDashboardScreen` |
| 1     | Notifications | `/parent/notification`  | `NotificationScreen`    |
| 2     | Profile       | `/parent/profile`       | `ParentProfileScreen`   |

No FAB. No dummy branch. All 3 indices map directly to real `StatefulShellBranch`es.

---

## Files

### New files

**`lib/features/dashboard/presentation/shell/parent_main_shell.dart`**
- `ParentMainShell` — outer `StatelessWidget`, injects `AppConfigurationBloc`, wraps `_ParentMainShellView`
- `_ParentMainShellView` — `StatefulWidget`, handles notification permission flow in `initState` (same logic as `StudentMainShell`), deactivates FCM on `dispose`
- `_ParentShellBottomNavigationBar` — `StatelessWidget`, 3-destination `NavigationBar` (Home, Notifications, Profile); tab switch via `navigationShell.goBranch`

**`lib/features/dashboard/presentation/screens/parent_profile_screen.dart`**
- Placeholder `ParentProfileScreen` — `StatelessWidget` with a centred "Coming soon" body. Will be fleshed out in a future feature.

### Modified files

**`lib/core/app_router/route_names.dart`**
- Add `parentNotification = "/parent/notification"`
- Add `parentProfile = "/parent/profile"`

**`lib/core/app_router/app_router.dart`**
- Fix student shell: change import from `widgets/main_shell.dart` → `shell/student_main_shell.dart`, update usage from `MainShell` → `StudentMainShell`
- Convert `/parent/dashboard` flat `GoRoute` → `StatefulShellRoute.indexedStack` using `ParentMainShell` with 3 branches:
  - Branch 0: `/parent/dashboard` → `ParentDashboardScreen`
  - Branch 1: `/parent/notification` → `NotificationScreen`
  - Branch 2: `/parent/profile` → `ParentProfileScreen`

---

## Routing

The redirect logic in `AppRouter` is unchanged. Parent users with a selected child are routed to `RouteNames.parentDashboard` (`/parent/dashboard`), which is now the entry point of the parent shell. The shell handles the rest.

---

## Behaviour

- Notification permission bottom sheet shown on first entry (same flow as student).
- FCM deactivated on shell dispose (same as student).
- `AppConfigurationBloc` injected at the shell level — maintenance banner can be shown if needed in the future.
- Tab state preserved per branch (stateful stack).

---

## Out of Scope

- `ParentProfileScreen` content — placeholder only.
- Parent-specific notification filtering — uses shared `NotificationScreen` as-is.
- Any new DI registrations — no new singletons or factories needed.
