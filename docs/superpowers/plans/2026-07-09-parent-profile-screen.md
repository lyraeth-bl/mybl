# Parent Profile Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the `ParentProfileScreen` placeholder with a real screen showing parent overview (name/username/phone), a switchable children list (with confirm dialog), a settings entry, and logout.

**Architecture:** Follow the existing student `ProfileScreen` pattern — outer `StatelessWidget` provides a screen-scoped `AuthBloc`, inner view uses the already-global `ParentBloc` via `BlocBuilder` to drive loading/failure/ready states, and composes two new presentation-only widgets (overview card, children switcher) inside a `CustomScrollView`. No new BLoC/use case/repository — `ParentBloc.started`/`.childSelected` already cover every interaction.

**Tech Stack:** Flutter 3.41.8, `flutter_bloc`, `freezed`, `go_router`, existing `core/widgets/*` primitives, `AppLocalizations` (ARB-based l10n), `mocktail` for tests.

## Global Constraints

- Copyright header on every new Dart file (see CLAUDE.md "Absolute Rules").
- `@freezed abstract class` for entities/models, `@freezed sealed class` for BLoC events/states — not touched in this plan (no new BLoC).
- Business logic never in widgets — this plan's widgets are pure presentation, dispatching via callbacks the screen wires to `ParentBloc`.
- Lines ≤ 80 chars, arrow syntax for one-liners, no trailing comments.
- Use `Theme.of(context).colorScheme` / `.textTheme` — no hardcoded colors.
- Use `AppLocalizations.of(context)!` for all visible text — no literal strings.
- Use `num.h`/`num.w` and `List<Widget>.separatedBy(...)` instead of raw `SizedBox`.
- Run `dart run build_runner build --delete-conflicting-outputs` after any `@freezed`/`fromJson` change (not needed this plan — no freezed changes).
- Run `flutter gen-l10n` after editing `.arb` files so `AppLocalizations` regenerates.
- `dart format .` and `flutter analyze` must pass before considering any task done.

---

### Task 1: Add new l10n keys

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_id.arb`

**Interfaces:**
- Produces: `l10n.parentProfileChildrenTitle`, `l10n.parentProfileSwitchChildTitle`, `l10n.parentProfileSwitchChildMessage(String childName)`, `l10n.parentProfileSwitchChildSuccess(String childName)`, `l10n.cancel`, `l10n.confirm` — consumed by Task 3 and Task 5. `cancel`/`confirm` are generic dialog-button labels that don't exist anywhere in the app yet (no prior `showDialog` usage), so they're added here rather than reused.

- [ ] **Step 1: Add the 4 new keys to `app_en.arb`**

In `lib/l10n/app_en.arb`, change the final two lines from:

```json
  "reload": "Reload",
  "comingSoon": "Coming soon"
}
```

to:

```json
  "reload": "Reload",
  "comingSoon": "Coming soon",
  "parentProfileChildrenTitle": "Your children",
  "parentProfileSwitchChildTitle": "Switch active child?",
  "parentProfileSwitchChildMessage": "You'll now be viewing {childName}'s data.",
  "@parentProfileSwitchChildMessage": {
    "placeholders": {
      "childName": {
        "type": "String"
      }
    }
  },
  "parentProfileSwitchChildSuccess": "Switched to {childName}",
  "@parentProfileSwitchChildSuccess": {
    "placeholders": {
      "childName": {
        "type": "String"
      }
    }
  },
  "cancel": "Cancel",
  "confirm": "Confirm"
}
```

- [ ] **Step 2: Add the matching Indonesian keys to `app_id.arb`**

In `lib/l10n/app_id.arb`, change the final two lines from:

```json
  "reload": "Muat ulang",
  "comingSoon": "Segera hadir"
}
```

to:

```json
  "reload": "Muat ulang",
  "comingSoon": "Segera hadir",
  "parentProfileChildrenTitle": "Anak Anda",
  "parentProfileSwitchChildTitle": "Ganti anak aktif?",
  "parentProfileSwitchChildMessage": "Kamu akan melihat data {childName}.",
  "@parentProfileSwitchChildMessage": {
    "placeholders": {
      "childName": {
        "type": "String"
      }
    }
  },
  "parentProfileSwitchChildSuccess": "Beralih ke {childName}",
  "@parentProfileSwitchChildSuccess": {
    "placeholders": {
      "childName": {
        "type": "String"
      }
    }
  },
  "cancel": "Batal",
  "confirm": "Konfirmasi"
}
```

- [ ] **Step 3: Regenerate localizations**

Run: `flutter gen-l10n`
Expected: no errors; `lib/l10n/app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_id.dart` regenerate with the 4 new getters/methods.

- [ ] **Step 4: Verify the new getters exist**

Run: `grep -n "parentProfileChildrenTitle\|parentProfileSwitchChildTitle\|parentProfileSwitchChildMessage\|parentProfileSwitchChildSuccess\|String get cancel\|String get confirm" lib/l10n/app_localizations_en.dart`
Expected: 6 matches (method/getter declarations).

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/app_en.arb lib/l10n/app_id.arb lib/l10n/app_localizations.dart lib/l10n/app_localizations_en.dart lib/l10n/app_localizations_id.dart
git commit -m "feat(l10n): add parent profile children/switch-child strings"
```

---

### Task 2: `ParentProfileOverviewSection` widget

**Files:**
- Create: `lib/features/dashboard/presentation/widgets/parent_profile_overview_section.dart`
- Test: `test/features/dashboard/presentation/widgets/parent_profile_overview_section_test.dart`

**Interfaces:**
- Consumes: `ParentEntity` (`lib/features/user/domain/entities/parent_entity/parent_entity.dart`) — fields `nama`, `username`, `telpon` (all `String`, non-nullable).
- Produces: `ParentProfileOverviewSection({required ParentEntity parent})`, a `StatelessWidget` returning a `SliverToBoxAdapter` (matches `ProfileOverviewSection`'s API shape) — consumed by Task 5.

- [ ] **Step 1: Write the failing test**

Create `test/features/dashboard/presentation/widgets/parent_profile_overview_section_test.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/dashboard/presentation/widgets/parent_profile_overview_section.dart';
import 'package:my_bl/features/user/domain/entities/parent_entity/parent_entity.dart';
import 'package:my_bl/l10n/app_localizations.dart';

Widget _wrap(ParentEntity parent) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: CustomScrollView(
        slivers: [ParentProfileOverviewSection(parent: parent)],
      ),
    ),
  );
}

void main() {
  testWidgets('shows parent name, username, and phone', (tester) async {
    const parent = ParentEntity(
      id: 1,
      nama: 'budi santoso',
      username: 'budi.santoso',
      telpon: '081234567890',
    );

    await tester.pumpWidget(_wrap(parent));

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('budi.santoso'), findsOneWidget);
    expect(find.text('081234567890'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/dashboard/presentation/widgets/parent_profile_overview_section_test.dart`
Expected: FAIL — `parent_profile_overview_section.dart` does not exist (import error).

- [ ] **Step 3: Write the widget**

Create `lib/features/dashboard/presentation/widgets/parent_profile_overview_section.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../user/domain/entities/parent_entity/parent_entity.dart';

class ParentProfileOverviewSection extends StatelessWidget {
  const ParentProfileOverviewSection({super.key, required this.parent});

  final ParentEntity parent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          16.h,
          AppFramedContainer(
            gap: .zero,
            elevation: 0,
            child: Column(
              children: [
                AppProfilePicture(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  initials: AppProfilePicture.initialFrom(parent.nama),
                  radius: 48,
                ),
                24.h,
                Text(
                  parent.nama.capitalizeEveryWord,
                  textAlign: .center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                8.h,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.alternate_email,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    Text(
                      parent.username,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ].separatedBy(4.w),
                ),
                4.h,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    Text(
                      parent.telpon,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ].separatedBy(4.w),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/dashboard/presentation/widgets/parent_profile_overview_section_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard/presentation/widgets/parent_profile_overview_section.dart test/features/dashboard/presentation/widgets/parent_profile_overview_section_test.dart
git commit -m "feat(dashboard): add parent profile overview section"
```

---

### Task 3: `ParentProfileChildrenSection` widget

**Files:**
- Create: `lib/features/dashboard/presentation/widgets/parent_profile_children_section.dart`
- Test: `test/features/dashboard/presentation/widgets/parent_profile_children_section_test.dart`

**Interfaces:**
- Consumes: `ChildEntity` (`nis`, `nama`, `kelas`, `profileImageUrl String?`) from `lib/features/user/domain/entities/child_entity/child_entity.dart`.
- Produces: `ParentProfileChildrenSection({required List<ChildEntity> children, required ChildEntity? selectedChild, required void Function(ChildEntity) onChildSelected})`, a `StatelessWidget` returning a sliver (`AppSliverGroup`) — consumed by Task 5. `onChildSelected` is only invoked *after* the user confirms the dialog, and never for the already-active child.

- [ ] **Step 1: Write the failing tests**

Create `test/features/dashboard/presentation/widgets/parent_profile_children_section_test.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/dashboard/presentation/widgets/parent_profile_children_section.dart';
import 'package:my_bl/features/user/domain/entities/child_entity/child_entity.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/l10n/app_localizations_en.dart';

final AppLocalizationsEn _l10n = AppLocalizationsEn();

const _budi = ChildEntity(nis: '111', nama: 'Budi', kelas: 'XI A');
const _sari = ChildEntity(nis: '222', nama: 'Sari', kelas: 'X B');

Widget _wrap({
  required List<ChildEntity> children,
  required ChildEntity? selectedChild,
  required void Function(ChildEntity) onChildSelected,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: CustomScrollView(
        slivers: [
          ParentProfileChildrenSection(
            children: children,
            selectedChild: selectedChild,
            onChildSelected: onChildSelected,
          ),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('tapping the already-active child shows no dialog and does '
      'not call onChildSelected', (tester) async {
    var called = false;

    await tester.pumpWidget(
      _wrap(
        children: const [_budi, _sari],
        selectedChild: _budi,
        onChildSelected: (_) => called = true,
      ),
    );

    await tester.tap(find.text('Budi'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(called, isFalse);
  });

  testWidgets('tapping a different child shows a confirm dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        children: const [_budi, _sari],
        selectedChild: _budi,
        onChildSelected: (_) {},
      ),
    );

    await tester.tap(find.text('Sari'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(_l10n.parentProfileSwitchChildTitle), findsOneWidget);
    expect(
      find.text(_l10n.parentProfileSwitchChildMessage('Sari')),
      findsOneWidget,
    );
  });

  testWidgets('confirming the dialog calls onChildSelected with the child', (
    tester,
  ) async {
    ChildEntity? selected;

    await tester.pumpWidget(
      _wrap(
        children: const [_budi, _sari],
        selectedChild: _budi,
        onChildSelected: (child) => selected = child,
      ),
    );

    await tester.tap(find.text('Sari'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_l10n.confirm));
    await tester.pumpAndSettle();

    expect(selected, _sari);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/dashboard/presentation/widgets/parent_profile_children_section_test.dart`
Expected: FAIL — `parent_profile_children_section.dart` does not exist.

- [ ] **Step 3: Write the widget**

Create `lib/features/dashboard/presentation/widgets/parent_profile_children_section.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/domain/entities/child_entity/child_entity.dart';

class ParentProfileChildrenSection extends StatelessWidget {
  const ParentProfileChildrenSection({
    super.key,
    required this.children,
    required this.selectedChild,
    required this.onChildSelected,
  });

  final List<ChildEntity> children;
  final ChildEntity? selectedChild;
  final void Function(ChildEntity child) onChildSelected;

  Future<void> _handleTap(BuildContext context, ChildEntity child) async {
    if (child.nis == selectedChild?.nis) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.parentProfileSwitchChildTitle),
        content: Text(
          l10n.parentProfileSwitchChildMessage(child.nama.capitalizeEveryWord),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed ?? false) onChildSelected(child);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: l10n.parentProfileChildrenTitle,
      titleStyle: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface),
      child: AppFramedContainer(
        margin: .zero,
        innerPadding: .zero,
        gap: .zero,
        child: children.isEmpty
            ? Padding(
                padding: const .symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisSize: .min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    Text(
                      l10n.noData,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ].separatedBy(8.w),
                ),
              )
            : Column(
                children: children
                    .map(
                      (child) => _ChildTile(
                        child: child,
                        isActive: child.nis == selectedChild?.nis,
                        onTap: () => _handleTap(context, child),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}

class _ChildTile extends StatelessWidget {
  const _ChildTile({
    required this.child,
    required this.isActive,
    required this.onTap,
  });

  final ChildEntity child;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return ListTile(
      onTap: onTap,
      leading: AppProfilePicture(
        backgroundColor: colorScheme.inverseSurface,
        foregroundColor: colorScheme.onInverseSurface,
        imageUrl: child.profileImageUrl,
        initials: AppProfilePicture.initialFrom(child.nama),
        radius: 24,
      ),
      title: Text(
        child.nama.capitalizeEveryWord,
        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      ),
      subtitle: Padding(
        padding: const .only(top: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.school_outlined,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            Text(child.kelas),
          ].separatedBy(4.w),
        ),
      ),
      trailing: isActive
          ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
          : null,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/dashboard/presentation/widgets/parent_profile_children_section_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard/presentation/widgets/parent_profile_children_section.dart test/features/dashboard/presentation/widgets/parent_profile_children_section_test.dart
git commit -m "feat(dashboard): add parent profile children switcher section"
```

---

### Task 4: `ParentProfileLoadingSection` widget

**Files:**
- Create: `lib/features/dashboard/presentation/widgets/parent_profile_loading_section.dart`
- Test: `test/features/dashboard/presentation/widgets/parent_profile_loading_section_test.dart`

**Interfaces:**
- Produces: `ParentProfileLoadingSection()`, a `StatelessWidget` returning a `SliverToBoxAdapter` shimmer placeholder — consumed by Task 5.

- [ ] **Step 1: Write the failing test**

Create `test/features/dashboard/presentation/widgets/parent_profile_loading_section_test.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/dashboard/presentation/widgets/parent_profile_loading_section.dart';

void main() {
  testWidgets('renders a shimmer placeholder sliver', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomScrollView(slivers: [ParentProfileLoadingSection()]),
        ),
      ),
    );

    expect(find.byType(ParentProfileLoadingSection), findsOneWidget);
    expect(find.byType(SliverToBoxAdapter), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/dashboard/presentation/widgets/parent_profile_loading_section_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Write the widget**

Create `lib/features/dashboard/presentation/widgets/parent_profile_loading_section.dart` (mirrors student `ProfileLoadingSection` exactly, same shimmer sizes):

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';

/// Shimmer placeholder mirroring [ParentProfileOverviewSection] while the
/// parent profile is loading.
class ParentProfileLoadingSection extends StatelessWidget {
  const ParentProfileLoadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          16.h,
          AppFramedContainer(
            gap: .zero,
            elevation: 0,
            child: Column(
              children: [
                const Text('').toShimmer(
                  context,
                  width: 96,
                  height: 96,
                  borderRadius: .circular(48),
                ),
                24.h,
                const Text('').toShimmer(context, width: 160, height: 16),
                8.h,
                const Text('').toShimmer(context, width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/dashboard/presentation/widgets/parent_profile_loading_section_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard/presentation/widgets/parent_profile_loading_section.dart test/features/dashboard/presentation/widgets/parent_profile_loading_section_test.dart
git commit -m "feat(dashboard): add parent profile loading skeleton section"
```

---

### Task 5: Rewrite `ParentProfileScreen`

**Files:**
- Modify: `lib/features/dashboard/presentation/screens/parent_profile_screen.dart`
- Modify: `test/features/dashboard/presentation/screens/parent_profile_screen_test.dart`

**Interfaces:**
- Consumes:
  - `ParentBloc`/`ParentState`/`ParentEvent` (`lib/features/user/presentation/bloc/parent_bloc/parent_bloc.dart`) — states `initial()`, `loading()`, `failure(Failure)`, `ready({required ParentEntity parent, required List<ChildEntity> children, ChildEntity? selectedChild})`; event `ParentEvent.started({bool forceRefresh})`, `ParentEvent.childSelected(ChildEntity)`.
  - `AuthBloc`/`AuthState`/`AuthEvent` (`lib/features/auth/presentation/bloc/auth_bloc.dart`) — `AuthState.loading()`, `AuthState.successLogout()` (via `whenOrNull`), `AuthEvent.logoutRequested()`.
  - `SessionBloc`/`SessionEvent` (`lib/features/sessions/presentation/bloc/session_bloc.dart`) — `SessionEvent.loggedOut()`.
  - `ParentProfileOverviewSection` (Task 2), `ParentProfileChildrenSection` (Task 3), `ParentProfileLoadingSection` (Task 4).
  - `AppEmptyStateSliver`, `RefreshWrapper`/`blocRefresh`, `LogoutButton`, `AppToast` (all `core/widgets/*`).
  - `RouteNames.settings` (`core/app_router/app_router.dart`).
- Produces: `ParentProfileScreen` (`StatelessWidget`, no constructor params) — this is a routed screen (`RouteNames.parentProfile`), nothing else depends on its internals.

- [ ] **Step 1: Update the existing screen test to match the real screen**

`ParentProfileScreen` now reads `ParentBloc` from context (global provider in the real app via `app_bloc_provider.dart`, but tests must supply their own). Replace `test/features/dashboard/presentation/screens/parent_profile_screen_test.dart` entirely:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/core/failure/failure.dart';
import 'package:my_bl/core/internal/src/types.dart';
import 'package:my_bl/features/dashboard/presentation/screens/parent_profile_screen.dart';
import 'package:my_bl/features/user/domain/entities/child_entity/child_entity.dart';
import 'package:my_bl/features/user/domain/entities/parent_entity/parent_entity.dart';
import 'package:my_bl/features/user/domain/repositories/parent_repository.dart';
import 'package:my_bl/features/user/domain/usecases/fetch_parent_use_case.dart';
import 'package:my_bl/features/user/domain/usecases/read_children_use_case.dart';
import 'package:my_bl/features/user/domain/usecases/read_selected_child_use_case.dart';
import 'package:my_bl/features/user/domain/usecases/save_children_use_case.dart';
import 'package:my_bl/features/user/domain/usecases/save_selected_child_use_case.dart';
import 'package:my_bl/features/user/presentation/bloc/parent_bloc/parent_bloc.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/l10n/app_localizations_en.dart';

class _MockParentRepository extends Mock implements ParentRepository {}

final AppLocalizationsEn _l10n = AppLocalizationsEn();

const _budi = ChildEntity(nis: '111', nama: 'Budi', kelas: 'XI A');
const _parent = ParentEntity(
  id: 1,
  nama: 'siti aminah',
  username: 'siti.aminah',
  telpon: '081234567890',
);

ParentBloc _buildBloc(_MockParentRepository repository) {
  return ParentBloc(
    FetchParentUseCase(repository),
    SaveChildrenUseCase(repository),
    ReadChildrenUseCase(repository),
    SaveSelectedChildUseCase(repository),
    ReadSelectedChildUseCase(repository),
  );
}

Widget _wrap(ParentBloc bloc) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: BlocProvider<ParentBloc>.value(
      value: bloc,
      child: const ParentProfileScreen(),
    ),
  );
}

void main() {
  testWidgets('shows loading skeleton while fetching', (tester) async {
    final repository = _MockParentRepository();
    when(
      () => repository.readChildren(),
    ).thenAnswer((_) async => right(const <ChildEntity>[]));
    when(
      () => repository.readSelectedChild(),
    ).thenAnswer((_) async => right(null));
    when(
      () => repository.fetchParent(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer(
      (_) => Future.delayed(
        const Duration(milliseconds: 50),
        () => right(_parent),
      ),
    );

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    bloc.add(const ParentEvent.started());
    await tester.pump();

    expect(find.byType(Scaffold), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('shows failure state with retry', (tester) async {
    final repository = _MockParentRepository();
    when(
      () => repository.readChildren(),
    ).thenAnswer((_) async => right(const <ChildEntity>[]));
    when(
      () => repository.readSelectedChild(),
    ).thenAnswer((_) async => right(null));
    when(
      () => repository.fetchParent(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => left(const Failure.network()));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    bloc.add(const ParentEvent.started());
    await tester.pumpAndSettle();

    expect(find.text(_l10n.profileLoadFailedTitle), findsOneWidget);
  });

  testWidgets('shows parent overview and children on success', (
    tester,
  ) async {
    final repository = _MockParentRepository();
    when(
      () => repository.readChildren(),
    ).thenAnswer((_) async => right(const [_budi]));
    when(
      () => repository.readSelectedChild(),
    ).thenAnswer((_) async => right(_budi));
    when(
      () => repository.fetchParent(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => right(_parent));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    bloc.add(const ParentEvent.started());
    await tester.pumpAndSettle();

    expect(find.text('Siti Aminah'), findsOneWidget);
    expect(find.text('Budi'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/dashboard/presentation/screens/parent_profile_screen_test.dart`
Expected: FAIL — screen still shows `l10n.comingSoon` placeholder, none of the new text/widgets exist yet.

- [ ] **Step 3: Rewrite the screen**

Replace `lib/features/dashboard/presentation/screens/parent_profile_screen.dart` entirely:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_toast_type.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/logout_button.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../../../user/domain/entities/child_entity/child_entity.dart';
import '../../../user/domain/entities/parent_entity/parent_entity.dart';
import '../../../user/presentation/bloc/parent_bloc/parent_bloc.dart';
import '../widgets/parent_profile_children_section.dart';
import '../widgets/parent_profile_loading_section.dart';
import '../widgets/parent_profile_overview_section.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => di<AuthBloc>(),
      child: const _ParentProfileScreenView(),
    );
  }
}

class _ParentProfileScreenView extends StatelessWidget {
  const _ParentProfileScreenView();

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
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        appBar: AppTopBar(
          title: Text(l10n.profile),
          actions: [
            IconButton(
              onPressed: () => context.push(RouteNames.settings),
              tooltip: l10n.settings,
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: BlocBuilder<ParentBloc, ParentState>(
          builder: (context, parentState) {
            return parentState.maybeWhen(
              failure: (_) => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  AppEmptyStateSliver(
                    icon: Icons.face_retouching_off,
                    title: l10n.profileLoadFailedTitle,
                    message: l10n.profileLoadFailedSubtitle,
                    retryLabel: l10n.tryAgain,
                    onRetry: () => context.read<ParentBloc>().add(
                      const ParentEvent.started(forceRefresh: true),
                    ),
                  ),
                ],
              ),
              ready: (parent, children, selectedChild) =>
                  _ParentProfileReadyBody(
                    children: children,
                    selectedChild: selectedChild,
                    overview: parent,
                  ),
              orElse: () => const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [ParentProfileLoadingSection()],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ParentProfileReadyBody extends StatelessWidget {
  const _ParentProfileReadyBody({
    required this.overview,
    required this.children,
    required this.selectedChild,
  });

  final ParentEntity overview;
  final List<ChildEntity> children;
  final ChildEntity? selectedChild;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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

        return RefreshWrapper(
          onRefresh: () => blocRefresh<ParentBloc, ParentEvent, ParentState>(
            context: context,
            event: const ParentEvent.started(forceRefresh: true),
            isDone: (state) => state.maybeWhen(
              ready: (_, _, _) => true,
              failure: (_) => true,
              orElse: () => false,
            ),
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              ParentProfileOverviewSection(parent: overview),
              ParentProfileChildrenSection(
                children: children,
                selectedChild: selectedChild,
                onChildSelected: (child) {
                  context.read<ParentBloc>().add(
                    ParentEvent.childSelected(child),
                  );
                  AppToast.show(
                    context,
                    l10n.parentProfileSwitchChildSuccess(
                      child.nama.capitalizeEveryWord,
                    ),
                    type: AppToastType.success,
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LogoutButton(
                    onPressed: () => context.read<AuthBloc>().add(
                      const AuthEvent.logoutRequested(),
                    ),
                    isLoading: isLogoutLoading,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/dashboard/presentation/screens/parent_profile_screen_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 5: Run the full test suite, format, and analyze**

Run: `flutter test`
Expected: all tests pass (no regressions in other suites).

Run: `dart format .`
Expected: no files changed (or only newly-created files reformatted) — re-run `flutter test` if formatting touched any file.

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/dashboard/presentation/screens/parent_profile_screen.dart test/features/dashboard/presentation/screens/parent_profile_screen_test.dart
git commit -m "feat(dashboard): build real parent profile screen

Replaces the coming-soon placeholder with parent overview, a
switchable children list (confirm dialog + toast), settings entry,
and logout — mirrors the student ProfileScreen structure."
```

---

## Post-plan verification

- [ ] Manually run the app as a parent (`flutter run`), navigate to the profile tab:
  - With 1 linked child: overview card shows name/username/phone, single child row shown as active (checkmark), no dialog appears if tapped (already active).
  - With 2+ children (if a test parent account with multiple children is available): tapping a non-active child shows the confirm dialog; confirming updates the active child (reflected on dashboard tab) and shows the success toast.
  - Pull-to-refresh re-fetches via `ParentBloc.started(forceRefresh: true)`.
  - Settings icon navigates to `RouteNames.settings`.
  - Logout button logs out and routes to `/welcome` (via `SessionBloc`).
