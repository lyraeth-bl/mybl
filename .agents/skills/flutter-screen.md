# Flutter Screen Pattern

## Overview

Use this skill when creating screens in the presentation layer.
Trigger: user mentions "buat screen", "create screen", or after BLoC creation.

## File Location

```
lib/features/<feature_name>/presentation/screens/<feature_name>_screen.dart
```

## Core Structure

Every screen always has this two-layer pattern:

### Layer 1: Screen (outer) — StatelessWidget

- Injects BLoC(s) via `BlocProvider` or `MultiBlocProvider`
- Always uses `di<BlocName>()` inside `create`
- No UI logic here — just DI setup

### Layer 2: View (inner) — StatelessWidget or StatefulWidget

- Contains all UI
- Use `StatefulWidget` only when `initState` is needed (e.g. trigger initial event, setup animation)
- Named `_<FeatureName>View` (private)

## Existing UI Style in This Project

Screens in this project should match the existing style used by files such as:

- `lib/features/profile/presentation/screens/profile_screen.dart`
- `lib/features/attendance/presentation/screens/attendance_screen.dart`

Follow these UI conventions when creating new screens:

- Use `Scaffold` as the page root.
- Prefer `CustomScrollView` + slivers for scrollable pages.
- Prefer `SliverAppBar.medium` for page headers when the page scrolls.
- Use `BouncingScrollPhysics` on scrollable page bodies.
- Use `Theme.of(context).colorScheme` and `Theme.of(context).textTheme` instead
  of hard-coded colors/text styles.
- Use `AppLocalizations.of(context)!` for visible user-facing text.
- Reuse existing shared widgets from `core/widgets/` before creating new UI
  primitives, for example `CustomContainer`, `RefreshWrapper`, `LogoutButton`,
  and `ProfilePicture`.
- Reuse feature widgets from `presentation/widgets/` when the UI piece belongs
  to that feature, for example `ProfileCardMenu`, `Calendar`, and `Chart`.
- Use `RefreshWrapper` plus `blocRefresh` for pull-to-refresh screens.
- Use `RepaintBoundary` around expensive visual sections such as calendars,
  charts, or dense custom containers.
- Use `AnimatedSwitcher`, `TweenAnimationBuilder`, shimmer extensions, or
  existing animation extensions when the surrounding feature already uses them.
- Keep spacing consistent with the existing screens: usually `16` for horizontal
  page padding, `24` for larger vertical sections, and small gaps with
  `SizedBox`.
- Use Material widgets such as `IconButton.filledTonal`, `Card.filled`, and
  `LinearProgressIndicator` when they match the surrounding UI.

Do not create landing-page or marketing-style UI for app screens. Build the
actual working screen directly.

## Template

### Single BLoC

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/get_it_constant.dart';
import '../bloc/<feature_name>_bloc.dart';

class <FeatureName>Screen extends StatelessWidget {
  const <FeatureName>Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<<FeatureName>Bloc>(
      create: (context) => di<<FeatureName>Bloc>(),
      child: const _<FeatureName>View(),
    );
  }
}
```

### Multiple BLoCs

```dart
class <FeatureName>Screen extends StatelessWidget {
  const <FeatureName>Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<<BlocA>>(create: (context) => di<<BlocA>>()),
        BlocProvider<<BlocB>>(create: (context) => di<<BlocB>>()),
      ],
      child: const _<FeatureName>View(),
    );
  }
}
```

## Triggering Initial Events

Always use `addPostFrameCallback` inside `initState` — never trigger events directly inside `create`:

```dart
class _<FeatureName>ViewState extends State<_<FeatureName>View> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<<FeatureName>Bloc>().add(
        const <FeatureName>Event.someRequested(),
      );
    });
  }
}
```

Exception: if the event must fire AND show loading immediately (e.g. global BLoC),
it's acceptable to chain directly in `create`:

```dart
create: (context) => di<AppConfigurationBloc>()
  ..add(const AppConfigurationEvent.appConfigurationRequested()),
```

## BLoC Widgets Guide

### BlocBuilder — rebuild UI on state change

Use `buildWhen` when the widget only cares about part of the state:

```dart
BlocBuilder<<Name>Bloc, <Name>State>(
  buildWhen: (prev, curr) {
    final prevLoading = prev.maybeWhen(loading: () => true, orElse: () => false);
    final currLoading = curr.maybeWhen(loading: () => true, orElse: () => false);
    return prevLoading != currLoading;
  },
  builder: (context, state) {
    // build UI
  },
)
```

### BlocSelector — rebuild on single value change

Use when only one value from state is needed:

```dart
BlocSelector<<Name>Bloc, <Name>State, <ValueType>>(
  selector: (state) => state.maybeWhen(
    success: (data) => data.someField,
    orElse: () => defaultValue,
  ),
  builder: (context, value) {
    // build UI using value
  },
)
```

### BlocListener — side effects only (no UI)

Use for snackbars, navigation, triggering other BLoCs:

```dart
BlocListener<<Name>Bloc, <Name>State>(
  listener: (context, state) {
    state.whenOrNull(
      failure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.errorMessage ?? '')),
        );
      },
    );
  },
  child: child,
)
```

For error handling, extract as a dedicated wrapper widget:

```dart
class _ErrorHandlingListener extends StatelessWidget {
  const _ErrorHandlingListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<<Name>Bloc, <Name>State>(
      listener: (context, state) {
        state.whenOrNull(
          failure: (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.errorMessage ?? '')),
            );
          },
        );
      },
      child: child,
    );
  }
}
```

For success side effects (e.g. trigger another BLoC after login), use `BlocListener` inline with `listenWhen`:

```dart
BlocListener<<Name>Bloc, <Name>State>(
  listenWhen: (prev, curr) => curr.maybeWhen(
    successLogin: (_, _) => true,
    orElse: () => false,
  ),
  listener: (context, state) {
    state.whenOrNull(
      successLogin: (accessToken, _) {
        context.read<SessionBloc>().add(
          SessionEvent.loggedIn(accessToken: accessToken),
        );
      },
    );
  },
  child: child,
)
```

## Private Widgets

Break UI into private classes (`_<Name>`) to keep `build` methods clean.
Naming is free-form but should be descriptive:

```dart
class _SummaryCard extends StatelessWidget { ... }
class _AttendanceNavigationButton extends StatelessWidget { ... }
class _SignInButton extends StatelessWidget { ... }
```

Rules:

- Private widgets that are reusable across features → extract to `core/widgets/`
- Widgets reusable inside one feature → extract to
  `lib/features/<feature_name>/presentation/widgets/`
- Private widgets specific to one screen → keep in the same screen file
- Never put private widget classes in separate files unless they are reusable

## State to UI Rules

- Use `maybeWhen` / `whenOrNull` to derive UI data from BLoC state.
- Use records for grouped derived state when it makes `buildWhen` comparison
  clearer.
- Use `buildWhen` to rebuild only when the state data used by that widget
  changes.
- Use `BlocListener` for side effects such as logout/session events,
  navigation, and snackbars.
- Do not put fetch, parsing, validation, or business decisions in widgets.
- Widgets may dispatch BLoC events in response to user actions.
- For initial fetches, use `addPostFrameCallback` in `initState`.
- For loading UI, prefer the existing shimmer/loading pattern used nearby.
- For null or unavailable data, render a deliberate empty state or lightweight
  placeholder instead of crashing.

## Rules

- NEVER put UI in the outer Screen widget — only BLoC injection
- NEVER trigger events directly in `create` (exception: global BLoC chaining with `..add()`)
- ALWAYS use `addPostFrameCallback` for initial events in `initState`
- ALWAYS use `buildWhen` in `BlocBuilder` when the widget only reacts to part of the state
- ALWAYS use `BlocSelector` instead of `BlocBuilder` when only one value is needed
- ALWAYS use `maybeWhen` / `whenOrNull` for state pattern matching — never use `if/else` on state type
- ALWAYS use app localization for visible strings
- ALWAYS prefer theme colors and text styles over hard-coded styling
- NEVER put business logic in widgets — only UI and BLoC event dispatching
- ALWAYS add copyright header

## Anti-patterns

- DO NOT call `di<BlocName>()` outside of `BlocProvider.create`
- DO NOT use `BlocBuilder` when `BlocSelector` is enough
- DO NOT trigger initial events directly in `create` (use `addPostFrameCallback`)
- DO NOT put reusable widgets as private classes — move them to `core/widgets/`
- DO NOT use `when` instead of `maybeWhen` unless all states are handled
- DO NOT hard-code user-facing strings
- DO NOT introduce new one-off containers/buttons if an existing project widget
  already fits
- DO NOT skip the copyright header
