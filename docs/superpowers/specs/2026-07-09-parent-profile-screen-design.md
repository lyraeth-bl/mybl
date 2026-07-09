# Parent Profile Screen — Design Spec

Date: 2026-07-09

## Background

`ParentProfileScreen` (`lib/features/dashboard/presentation/screens/parent_profile_screen.dart`) is currently an intentional placeholder showing only `l10n.comingSoon`. `ParentBloc` (`lib/features/user/presentation/bloc/parent_bloc/`) already exposes everything needed to build a real screen: parent profile (`ParentEntity`: `id`, `nama`, `username`, `telpon`, from `/parent/me`), the list of linked children (`ChildEntity`: `nis`, `nama`, `kelas`, `profileImageUrl?`), and the currently selected/active child — all globally provided (`BlocProvider<ParentBloc>` in `app_bloc_provider.dart`).

Unlike `ParentDashboardScreen`, this doesn't touch the student-only endpoints blocked for parent tokens ([[parent-backend-multirole-pending]]) — `/parent/me` and the children list are parent-native endpoints, so this screen is safe to build now.

## Goals

- Replace the placeholder with a real profile screen: parent overview, children list with switch-active-child, settings entry, logout.
- Let a parent switch their active child from the profile tab (today only possible via the one-time post-login `ParentChildSelectorScreen`), with a confirmation dialog before the switch takes effect.
- Follow the existing student `ProfileScreen` structural pattern (`CustomScrollView` + slivers + `RefreshWrapper`) for consistency.

## Non-goals

- No "personal info" detail screen for the parent (unlike student's `ProfileDetailScreen`). `ParentEntity` only has 3 displayable fields (username, telpon, plus nama already on the overview card) — showing them inline on the overview card is enough; a whole extra screen for that is not justified.
- No editing of parent profile fields (name/phone/username) — display only.
- No changes to `ParentBloc`, its use cases, or `ParentChildSelectorScreen` — all reused as-is.

## Design

### Screen structure

`ParentProfileScreen` (outer `StatelessWidget`) wraps `BlocProvider<AuthBloc>` (factory, same as student `ProfileScreen`) around a private `_ParentProfileScreenView`.

`_ParentProfileScreenView`:
- `BlocListener<AuthBloc, AuthState>` → on `successLogout`, dispatch `SessionEvent.loggedOut()` to `SessionBloc` (identical to student `ProfileScreen`).
- `Scaffold` + `AppTopBar` (title `l10n.profile`, one action: settings `IconButton` → `context.push(RouteNames.settings)`).
- Body: `BlocBuilder<ParentBloc, ParentState>`:
  - `initial` / `loading` → `CustomScrollView` with a loading skeleton sliver (new `ParentProfileLoadingSection`, shimmer avatar + name/subtitle placeholders, same shimmer technique as student's `ProfileLoadingSection`).
  - `failure` → `CustomScrollView` with `AppEmptyStateSliver` (icon `Icons.face_retouching_off`, title `l10n.profileLoadFailedTitle`, message `l10n.profileLoadFailedSubtitle`, retry → `ParentEvent.started(forceRefresh: true)`) — reuses existing l10n keys, same as student screen's failure state.
  - `ready(parent, children, selectedChild)` → `RefreshWrapper` (`onRefresh` → `blocRefresh<ParentBloc, ParentEvent, ParentState>` with `event: ParentEvent.started(forceRefresh: true)`, `isDone` on `ready`/`failure`) wrapping `CustomScrollView` with 3 slivers:
    1. `ParentProfileOverviewSection(parent: parent)`
    2. `ParentProfileChildrenSection(children: children, selectedChild: selectedChild)`
    3. Logout-only menu sliver (inline `SliverToBoxAdapter` wrapping `LogoutButton`, matching `ProfileMenuSection`'s logout row but dropping the personal-info row — not a whole new widget file since it's a single row).

### `ParentProfileOverviewSection` (new)

Location: `lib/features/dashboard/presentation/widgets/parent_profile_overview_section.dart`.

Mirrors `ProfileOverviewSection` layout (`AppFramedContainer`, `AppProfilePicture` initials-only — `ParentEntity` has no image field — centered name), plus two extra rows below the name for `parent.username` and `parent.telpon` (icon + label, e.g. `Icons.alternate_email` / `Icons.phone_outlined`), using `l10n.username` / `l10n.phoneNumber` as accessible labels (not shown as visible text, values are — matches how `_ChildrenDetail` shows nis/kelas inline with icons).

### `ParentProfileChildrenSection` (new)

Location: `lib/features/dashboard/presentation/widgets/parent_profile_children_section.dart`.

`AppSliverGroup` (title: new l10n key `parentProfileChildrenTitle`) wrapping a `Column` of child rows, one per `ChildEntity`, styled like the existing `_ChildCard` in `parent_child_selector_screen.dart` (avatar/initials, name, kelas + nis row, trailing check icon when active) but as a private widget local to this file (no cross-file extraction — only used here).

Tap behavior:
- If tapped child's `nis == selectedChild?.nis` → no-op (already active).
- Else → show `AlertDialog` (title: new l10n key `parentProfileSwitchChildTitle`, content: new l10n key `parentProfileSwitchChildMessage(childName)`, actions: cancel / confirm). On confirm: dispatch `ParentEvent.childSelected(child)` to `context.read<ParentBloc>()`, then `AppToast.success(context, l10n.parentProfileSwitchChildSuccess(childName))`.

Empty children list → reuse the same `_ChildrenEmptyState`-style row already patterned in `ParentDashboardProfileSection` (small private widget here, `l10n.noData`) — no new l10n key needed.

### New l10n keys (`app_en.arb` + `app_id.arb`)

- `parentProfileChildrenTitle` — e.g. en: "Your children" / id: "Anak Anda"
- `parentProfileSwitchChildTitle` — e.g. en: "Switch active child?" / id: "Ganti anak aktif?"
- `parentProfileSwitchChildMessage` (placeholder `childName`) — e.g. en: "You'll now be viewing {childName}'s data." / id: "Kamu akan melihat data {childName}."
- `parentProfileSwitchChildSuccess` (placeholder `childName`) — e.g. en: "Switched to {childName}" / id: "Beralih ke {childName}"

Reused existing keys: `profile`, `settings`, `profileLoadFailedTitle`, `profileLoadFailedSubtitle`, `tryAgain`, `username`, `phoneNumber`, `noData`.

### Files touched

- Rewrite: `lib/features/dashboard/presentation/screens/parent_profile_screen.dart`
- New: `lib/features/dashboard/presentation/widgets/parent_profile_overview_section.dart`
- New: `lib/features/dashboard/presentation/widgets/parent_profile_children_section.dart`
- New: `lib/features/dashboard/presentation/widgets/parent_profile_loading_section.dart`
- Edit: `lib/l10n/app_en.arb`, `lib/l10n/app_id.arb` (4 new keys each)

No new BLoC, use case, repository, or DI changes — `ParentBloc.started`/`.childSelected` already cover every interaction this screen needs.

## Testing

- Widget test for `ParentProfileChildrenSection`: tapping an already-active child shows no dialog; tapping a different child shows the confirm dialog; confirming dispatches `childSelected`.
- Manual: run app as parent with 1 child (auto-selected, no dialog needed since no other option), and with 2+ children (switch flow end-to-end), verify loading/failure/ready states via `ParentBloc` state changes.
