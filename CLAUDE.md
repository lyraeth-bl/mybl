# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MyBL is a Flutter mobile app (student portal) for the Budi Luhur school ecosystem. It connects to backend APIs (SPO + internal) to expose academic data: attendance, grades, schedule, extracurricular, merit/demerit, calendar, and notifications. Users can be students or parents (with child-selection flow).

Flutter version: **3.44.8** (stable channel).

**Stack:**

- **State management**: `flutter_bloc` + `freezed`
- **Functional programming**: `fpdart` (`Result`, `Either`, `Unit`)
- **Local storage**: `hive_ce` for regular data, `flutter_secure_storage` for sensitive data
- **HTTP**: custom `HTTPRequest` abstraction via `data_interfaces.dart`
- **Dependency injection**: `get_it`
- **Navigation**: `go_router`

## Commands

```bash
# Install dependencies
flutter pub get

# Generate Freezed, JSON Serializable, and Hive code (run after any @freezed or fromJson change)
dart run build_runner build --delete-conflicting-outputs

# Format
dart format .

# Analyze / lint
flutter analyze

# Run app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart
```

CI runs `pub get → build_runner → dart format --set-exit-if-changed → flutter analyze` on PRs to `dev` or `main`.

### Package Management

```bash
flutter pub add <package>          # regular dependency
flutter pub add dev:<package>      # dev dependency
dart pub remove <package>          # remove
```

Before adding a package, search pub.dev to confirm it is the most suitable and actively maintained option. Do not add a third-party dependency unless the existing stack cannot handle the requirement cleanly. Explain the benefit of any new dependency. The project already standardises on `flutter_bloc`, `freezed`, `fpdart`, `hive_ce`, `flutter_secure_storage`, `get_it`, and `go_router`.

## Absolute Rules

- Always add this copyright header at the top of every standalone Dart file:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.
```

- Use `@freezed abstract class` for entities and models.
- Use `@freezed sealed class` for BLoC events and states.
- BLoC `part` files (`*_event.dart`, `*_state.dart`) start with `part of '<name>_bloc.dart';`.
- Run `dart run build_runner build --delete-conflicting-outputs` after any `@freezed` or `fromJson` change.
- Never put business logic in widgets or BLoCs. Business rules belong in use cases and repositories.
- Prefer existing project abstractions and patterns over adding new ones.
- Keep UI logic in widgets, app state in BLoCs, business flow in use cases, and IO/error handling in repositories and data sources.

## Architecture

Clean Architecture per feature. Each feature is split into three layers: `domain`, `data`, and `presentation`.

```
lib/
├── core/                      # Cross-feature infrastructure
│   ├── app/                   # App init (initialize_app.dart), BLoC observer, root widget
│   ├── app_router/            # go_router config + RouteNames + redirect logic
│   ├── api_client/            # HTTPRequest implementation (Dio-backed)
│   ├── di/                    # GetIt instance — di<T>() resolver (get_it_constant.dart)
│   ├── internal/src/
│   │   ├── interfaces/data_interfaces.dart   # All shared data-layer interfaces
│   │   ├── extensions/extensions.dart        # Shared extensions (shimmer, animate, spacing…)
│   │   └── types.dart                        # Result<T> = Either<Failure, T>
│   ├── failure/               # Failure.fromError(e, st) for repository errors
│   ├── storage/               # Hive boxes lifecycle (open/clear/close use cases)
│   └── widgets/               # Shared UI primitives (AppButton, AppTextField…)
└── features/<name>/
    ├── domain/
    │   ├── entities/          # @freezed abstract class, no fromJson/toJson
    │   ├── repositories/      # abstract class implementing data interfaces
    │   └── usecases/          # One class per method, call() only, no async/await
    ├── data/
    │   ├── models/            # @freezed abstract class with fromJson + toEntity()
    │   ├── datasources/       # remote.dart / local.dart (abstract + impl)
    │   └── repositories/      # Impl: try/catch → Failure.fromError, model→entity
    ├── presentation/
    │   ├── bloc/              # *_bloc.dart + *_event.dart + *_state.dart
    │   ├── cubit/             # *_cubit.dart + *_state.dart (for mini state)
    │   ├── screens/           # Outer StatelessWidget (BLoC injection) + private view
    │   └── widgets/           # Feature-scoped UI components
    └── di.dart                # Feature DI registration (GetIt)
```

Cubits live in `presentation/cubit/<name>/`, not `presentation/bloc/` — bloc/ is for full Bloc (event+state), cubit/ is for Cubit (state only, no event).

### Dependency Injection

All DI bootstrapping runs in `lib/core/app/initialize_app.dart`. Each feature exports an `init<Feature>DI()` function called there in dependency order. Use `di<T>()` (from `lib/core/di/get_it_constant.dart`) to resolve. Use `di<BlocName>()` only inside `BlocProvider.create`. Infrastructure (`HiveInterface`, `FlutterSecureStorage`, `HTTPRequest`) is registered in core DI — never re-register these inside a feature.

- Use `registerLazySingleton` for data sources, repositories, use cases, and global/shared BLoCs.
- Use `registerFactory` for per-screen BLoCs/Cubits.
- Global BLoCs manage app-wide state that must persist across screens (e.g. `SessionBloc`, `AppConfigurationBloc`).
- `UserBloc` is currently a lazy singleton because user state is shared by profile-related screens.
- Do not reorder existing DI files for style; preserve the local file style unless it causes a real bug.

**`registerLazySingleton` examples:**

- `SessionBloc` — app-wide auth state, read by `AppRouter`'s redirect via `GoRouterRefreshStream.merged`; must outlive any single screen.
- `UserBloc` — user/student data shared across multiple profile-related screens; refetching per screen would waste calls and desync state.

**`registerFactory` examples:**

- `AuthBloc` — scoped to the login screen only; disposed once login completes/screen closes, no reason to keep it alive after.
- `RememberMeCubit` — scoped to the auth screen's login form; simple checkbox toggle, no cross-screen relevance.

### Routing

`AppRouter` (`lib/core/app_router/app_router.dart`) uses `go_router`. The `redirect` callback listens to both `SessionBloc` and `ParentBloc` streams via `GoRouterRefreshStream.merged`. Logic:

- Not logged in → `/welcome`
- Logged in as student → `/dashboard`
- Logged in as parent, no child selected → `/parent-child-selector`
- Use `RouteNames.*` constants for all navigation calls.
- Use `Navigator` only for temporary views (dialogs, short-lived flows) that do not need deep links.

### Auth / Session Flow

Two user roles: `UserRole.student` and `UserRole.parent`. `SessionBloc` manages auth state (`initial → loading → authenticated(token, role) | unauthenticated`). `ParentBloc` manages parent's selected child (`initial → active(child)`). Both are global lazy singletons.

### Data Interfaces

All shared data-layer contracts live in `lib/core/internal/src/interfaces/data_interfaces.dart`. Reuse existing interfaces before adding new ones. Always check the bottom of the file for project-specific interfaces.

| Interface                   | Use when                               |
| --------------------------- | -------------------------------------- |
| `ItemFetcher<T>`            | Fetch one item from API/cache          |
| `ListFetcher<T>`            | Fetch a list from API/cache            |
| `CacheStorage<T>`           | Save/read one local data type          |
| `ListCacheStorage<T>`       | Save/read list local data type         |
| `Authenticator<T>`          | Login/logout                           |
| `RememberMeStorage`         | Persist NIS for remember me            |
| `TokenStorage`              | Manage access token                    |
| `LocalStorageManager`       | Manage local database boxes            |
| `AttendanceFetcher<T>`      | Fetch daily/monthly attendance         |
| `AttendanceLocalManager<T>` | Cache daily/monthly attendance in Hive |

Rules:

- New interfaces use `abstract interface class` and are added at the bottom of `data_interfaces.dart`.
- Fetch methods include `{bool forceRefresh = false}` when cache bypass matters.
- Fetcher interfaces may be implemented by domain repositories.
- Local manager interfaces are data-layer only — never implemented by domain repositories.

### BLoC Conventions

- Initial state: `const <Name>State.initial()`.
- Emit `loading()` before async operations.
- Handle `Result<T>` with `result.match(...)`, not `fold()` or manual `if/else`.
- Use `return result.match(...)` for simple single-expression handlers.
- Do not emit after `result.match()` outside the callbacks.
- State must have at least `initial`, `loading`, and `failure`.
- Private handlers are named `_on<EventName>`.
- `BlocListener` — side effects only (navigation, toasts, triggering sibling blocs). Use `listenWhen` to filter.
- `BlocBuilder` — UI rebuilds only. Use `buildWhen` to avoid unnecessary rebuilds.
- `BlocSelector` when only one value is needed.
- Use `maybeWhen` and `whenOrNull`; avoid state-type `if/else`.

### Bloc vs Cubit

- **Bloc:** multiple distinct triggers that map to named events, or a handler needs to branch on _which_ thing happened. `SessionBloc` (`Started`/`LoggedIn`/`LoggedOut`), `AuthBloc` (`LoginRequested`/`LoginParentRequested`/`LogoutRequested`), `UserBloc` (`FetchStudentRequested`) — each has 2+ event types with different handling logic.
- **Cubit:** one simple piece of state changed via direct method calls, no need to distinguish "why" it changed. `RememberMeCubit` — just toggles a boolean, no event vocabulary needed.
- Default to Bloc when in doubt — it's the project's dominant pattern. Reach for Cubit only when an event type would be pure ceremony around a single setter-like action.

## Feature Creation Order

When creating a new feature, always follow this order. Each layer depends on the one before it. Do not skip or reverse steps.

1. Folder structure
2. Domain entity
3. Data interface (only if a new interface is needed)
4. Domain repository
5. Use cases
6. Data models
7. Remote data source
8. Local data source (only if caching or local persistence is needed)
9. Repository implementation
10. BLoC
11. Screen
12. DI registration

## Layer Patterns

### Feature Folder

```text
lib/features/<feature_name>/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── bloc/
│   ├── cubit/
│   ├── screens/
│   └── widgets/
└── di.dart
```

Initial `di.dart` contains only the copyright header and an empty DI function:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

void init<FeatureName>DI() {}
```

Do not create other files during the folder-structure step.

### Entity

- Location: `lib/features/<feature_name>/domain/entities/<entity_name>/<entity_name>.dart`
- Use `@freezed abstract class`. No `fromJson`/`toJson`.
- No IO, validation flow, or workflow logic inside entities.
- Simple derived getters are allowed when deterministic and using only the entity's own fields.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '<entity_name>.freezed.dart';

@freezed
abstract class <EntityName> with _$<EntityName> {
  const factory <EntityName>({
    // fields
  }) = _<EntityName>;
}
```

### Domain Repository

- Location: `lib/features/<feature_name>/domain/repositories/<feature_name>_repository.dart`
- Use `abstract class`, not `abstract interface class`.
- Implement fetcher/auth/storage contracts that belong at the repository level.
- Never implement local manager interfaces in the domain repository.

```dart
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/<entity_name>/<entity_name>.dart';

abstract class <FeatureName>Repository
    implements <InterfaceName><<EntityName>> {}
```

### Use Case

- Location: `lib/features/<feature_name>/domain/usecases/<method_name>_use_case.dart`
- One repository method → one use case class → one file.
- Use `call()` only. Do not use `async`/`await`; forward directly to the repository.
- Use direct parameters for ≤ 3 input fields. Create a `Params` entity for > 3 fields or cohesive form inputs.

```dart
import '../../../../core/internal/src/types.dart';
import '../repositories/<feature_name>_repository.dart';

class <MethodName>UseCase {
  <MethodName>UseCase(this._<featureName>Repository);

  final <FeatureName>Repository _<featureName>Repository;

  Future<Result<<ReturnType>>> call(<params>) =>
      _<featureName>Repository.<methodName>(<args>);
}
```

### Model

- Location: `lib/features/<feature_name>/data/models/<model_name>/<model_name>.dart`
- Use `@freezed abstract class`.
- Base models mirror entities and include `fromJson` + `toEntity()`.
- Response/DTO models wrap full API responses and include `fromJson` only — no `toEntity()`.
- Prefer explicit `@JsonKey(name: '...')` on API-backed fields, even for identical names.
- Use `@Default(value)` when API data can be null but Dart needs a default.
- Do not manually write `toJson()`.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/<entity_name>/<entity_name>.dart';

part '<model_name>.freezed.dart';
part '<model_name>.g.dart';

@freezed
abstract class <ModelName> with _$<ModelName> {
  const factory <ModelName>({
    // fields
  }) = _<ModelName>;

  factory <ModelName>.fromJson(Map<String, dynamic> json) =>
      _$<ModelName>FromJson(json);
}

extension <ModelName>Mapper on <ModelName> {
  <EntityName> toEntity() => <EntityName>(
        // mappings
      );
}
```

### Remote Data Source

- Location: `lib/features/<feature_name>/data/datasources/<feature_name>_remote_data_source.dart`
- Each file has an abstract contract and an implementation.
- Inject `HTTPRequest`, never concrete HTTP clients.
- Return response/DTO models, never entities or raw maps.
- For POST/PUT, call `.toJson()` on request models.
- For GET query params, define `final Map<String, dynamic> query = {...}` first.
- For `Unit` methods, return `unit` after the request completes.
- Do not handle repository-level business errors here.

### Local Data Source

- Location: `lib/features/<feature_name>/data/datasources/<feature_name>_local_data_source.dart`
- Use `FlutterSecureStorage` for sensitive data (tokens, credentials).
- Use `HiveInterface` for regular model/cache data.
- Always implement `LocalManager`, `CacheStorage`, or another interface from `data_interfaces.dart`.
- For Hive reads, call `Map<String, dynamic>.from(rawData)` before `fromJson`.
- For Hive writes, save `model.toJson()`.
- For list data in Hive, cast to `List<dynamic>` and map each item through `fromJson`.
- Return `unit` after successful writes.

### Repository Implementation

- Location: `lib/features/<feature_name>/data/repositories/<feature_name>_repository_impl.dart`
- Always implement the domain repository.
- Remote calls use `try/catch` and wrap errors with `Failure.fromError(e, st)`.
- Local-only methods delegate directly — no `try/catch` needed.
- Always convert models to entities before returning.
- Do not throw raw exceptions.
- Add `forceRefresh` only when the method has cache behavior.

**Cache flow:** check local → return if available → else fetch remote → save locally → return entity.

**Remote-only flow:** build request model → call remote data source → convert to entity → return `right(entity)` or `left(Failure.fromError(e, st))`.

**Local-only flow:** delegate to local data source → return result directly.

### BLoC

Three files: `_bloc.dart`, `_event.dart`, `_state.dart`.

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '<name>_bloc.freezed.dart';
part '<name>_event.dart';
part '<name>_state.dart';

class <Name>Bloc extends Bloc<<Name>Event, <Name>State> {
  <Name>Bloc(this._useCase) : super(const <Name>State.initial()) {
    on<_<EventName>>(_on<EventName>);
  }

  final <UseCase> _useCase;
}
```

- Put presentation-specific transformations in private static helper methods. Shared business rules belong in domain.

### Screen

- Location: `lib/features/<feature_name>/presentation/screens/<feature_name>_screen.dart`
- Two layers: outer `Screen` (`StatelessWidget`, injects BLoCs only) + inner private view (contains UI).
- Use `Scaffold` as the page root.
- Prefer `CustomScrollView` with slivers for scrollable screens; `SliverAppBar.medium` for scrollable headers.
- Use `AlwaysScrollableScrollPhysics` for main scroll views.
- Use `Theme.of(context).colorScheme` and `Theme.of(context).textTheme` — no hard-coded colors or text styles.
- Use `AppLocalizations.of(context)!` for all visible text.
- Use `RefreshWrapper` and `blocRefresh` for pull-to-refresh pages.
- Use `RepaintBoundary` around expensive visual sections (charts, calendars, dense containers).
- Use records for grouped derived state when that keeps `buildWhen` clear.
- Trigger initial events in `initState` via `WidgetsBinding.instance.addPostFrameCallback`.
- Keep common spacing close to existing screens: `16` for horizontal page padding, `24` for larger vertical sections.
- Keep private widgets in the screen file unless reusable across features. Feature-reusable widgets go in `presentation/widgets/`; cross-feature widgets in `core/widgets/`.

## Decision Guide

**Which interface should a domain repository use?** Check the Data Interfaces table above, determine what the repository needs to do, ask when behavior is unclear.

**When to add a new interface?** Only when no existing interface covers the need.

**`registerLazySingleton` vs `registerFactory`?** Global/app-wide BLoC → `registerLazySingleton`. Per-screen BLoC → `registerFactory`.

**When to use a `Params` class?** Only when a use case needs more than 3 input fields.

**When to add a local data source?** Only when the feature needs local cache or persistence. Sensitive data → `FlutterSecureStorage`. Regular data → `HiveInterface`.

## Dart & Flutter Guidelines

### Dart Style

Follow [Effective Dart](https://dart.dev/effective-dart).

- `PascalCase` for classes/enums, `camelCase` for members/variables/functions, `snake_case` for files.
- Lines ≤ 80 characters. Functions ≤ 20 lines with a single purpose.
- Use arrow syntax for simple one-line functions.
- No trailing comments. Use `///` for public API doc comments.
- Use meaningful, descriptive names. Avoid abbreviations.
- Prefer immutable data structures.

### Dart Best Practices

- **Null safety:** Avoid `!` unless the value is guaranteed non-null.
- **Async:** Use `Future`/`async`/`await` for single async operations; `Stream` for sequences.
- **Pattern matching:** Use where it simplifies code.
- **Records:** Return multiple values with records instead of defining a one-off class.
- **Switch:** Prefer exhaustive `switch` expressions — no `break` needed.
- **Exceptions:** Use `try-catch` with typed or custom exceptions. Never fail silently.
- **Logging:** Use `dart:developer`'s `log()` — never `print()`.

```dart
import 'dart:developer' as developer;

try {
  // ...
} catch (e, s) {
  developer.log('Failed to fetch data',
      name: 'myapp.network', level: 1000, error: e, stackTrace: s);
}
```

### Flutter Best Practices

- **Composition over inheritance:** Build complex widgets by composing smaller ones.
- **Private widgets:** Extract reusable parts into private `Widget` classes, not helper methods that return `Widget`.
- **Const constructors:** Use `const` wherever possible in `build()` to reduce rebuilds.
- **Long lists:** Use `ListView.builder` or slivers — never a `children: [...]` loop.
- **Expensive work:** Never do network calls or heavy computation inside `build()`. Use `compute()` for CPU-heavy tasks.

### Theming

- Define one `ThemeData` for light and one for dark; pass both to `MaterialApp`.
- Generate palettes with `ColorScheme.fromSeed(seedColor: ..., brightness: ...)`.
- Customise individual components via `appBarTheme`, `elevatedButtonTheme`, etc. — not inline styles.
- Use `ThemeExtension<T>` for custom design tokens not in standard `ThemeData`.
- Use `WidgetStateProperty.resolveWith` to style interactive states (pressed, disabled, hovered).
- Custom fonts: use `google_fonts` and define a `TextTheme` — don't hardcode font names in widgets.

### Layout

- `Expanded` to fill remaining space; `Flexible` to shrink-to-fit. Don't mix both in the same `Row`/`Column`.
- `Wrap` when items would overflow a row/column and should reflow.
- `LayoutBuilder` for responsive decisions based on available constraints.
- `Stack` + `Positioned`/`Align` for layered widgets; `OverlayPortal` for floating UI (tooltips, dropdowns).

### Assets & Images

- Declare all assets in `pubspec.yaml` under `flutter: assets:`.
- Local images: `Image.asset(...)`.
- Network images: `Image.network(...)` — always provide `loadingBuilder` and `errorBuilder`.
- Cached network images: use `cached_network_image`.

### Accessibility

- Text contrast ratio ≥ 4.5:1 (normal text) and ≥ 3:1 (large text, 18pt+).
- Test with dynamic font scaling — ensure layout doesn't break at large sizes.
- Add `Semantics` labels to interactive elements that lack visible text.
- Verify with TalkBack (Android) and VoiceOver (iOS).

### Mobile UI/UX Rules

- **Typography:** max 2 font families, max 4 font weights. Already satisfied by `lib/core/theme/app_theme.dart` — Inter (body/label) + Plus Jakarta Sans (display/headline/title, `w600`/`w700`). Don't introduce a third family or a fifth weight; extend the existing `textTheme.copyWith(...)` instead.
- **Color ratio:** 60% dominant/background, 30% brand/primary, 10% accent (CTAs). Already satisfied via `ColorScheme.fromSeed` (one seed color) — no change needed. Use `AppColors.of(context)` (the `success`/`warning` `ThemeExtension`) for semantic colors instead of hardcoding.
- **Spacing:** all padding/sizing on 8pt grid (or 4pt fine-grained). Use `num.h`/`num.w` (`16.h`, `8.w`) and `List<Widget>.separatedBy(separator)` from `lib/core/internal/src/extensions/extensions.dart` instead of raw `SizedBox`.
- **Touch targets:** min 48×48dp, min 8dp gap between tappable elements. `IconButton` enforces 48dp by default; `AppButton`'s `_defaultMinimumSize` is already `Size.fromHeight(48)`.
- **Visual hierarchy:** one primary CTA per screen. Use `AppButton` (filled) for primary, `AppButton.outlined` for secondary, `AppButton.text` for tertiary/low-emphasis actions — never style secondary/tertiary the same as primary.
- **Feedback states:** every interactive element handles loading, empty, error, success, disabled. Use one consistent toast/snackbar pattern app-wide — never ad-hoc `ScaffoldMessenger.of(context).showSnackBar`.
- **Navigation:** max 5 bottom nav items — `StudentMainShell`/`ParentMainShell` (`lib/features/dashboard/presentation/shell/`) each use 3. Predictable patterns — users always know where they are.
- **Thumb zone:** primary CTAs/bottom nav in bottom-center — already the pattern via `NavigationBar` in both shells above.
- **Motion:** transitions 200–300ms, `Curves.easeInOut`/`easeOut`/`easeIn`. Respect `MediaQuery.of(context).disableAnimations`. Prefer implicit animations (`AnimatedContainer` etc.) unless multi-step/interruptible needs `AnimationController`.
- **Dark mode:** already handled — `MyBlTheme.lightTheme`/`darkTheme` both derive from `ColorScheme.fromSeed(brightness: ...)`, never hardcode colors. Always read colors via `Theme.of(context).colorScheme`; never hardcode a background color (pure black or otherwise).

### Testing

- Unit tests: `package:test` — cover domain logic, data layer, state management.
- Widget tests: `package:flutter_test` — cover UI components.
- Integration tests: `package:integration_test` (Flutter SDK dev dependency).
- Assertions: prefer `package:checks` over default matchers.
- Prefer fakes/stubs over mocks. Use `mocktail` only when necessary.
- Follow Arrange-Act-Assert (Given-When-Then) in all tests.

## Engineering Principles

- **DRY:** Eliminate duplicated logic by extracting shared utilities and modules.
- **SRP:** Every class, module, function, and file has exactly one reason to change.
- **Clear abstractions:** Expose intent through small, stable interfaces; hide implementation details.
- **Low coupling, high cohesion:** Keep modules self-contained and minimize cross-dependencies.
- **KISS:** Keep solutions as simple as possible.
- **YAGNI:** Avoid speculative complexity or over-engineering.
- Apply SOLID principles and prefer composition over inheritance.

## Shared Widgets

All shared widgets live in `lib/core/widgets/`. Always reach for these before writing a one-off `TextFormField`, `ElevatedButton`, `OutlinedButton`, `TextButton`, or toast call — never bypass them with raw Material widgets.

| Widget                                  | Use when                                                              |
| --------------------------------------- | --------------------------------------------------------------------- |
| `AppButton` (+ `.outlined`, `.text`)    | Primary/secondary/tertiary action buttons with loading state          |
| `AppTextField`                          | Form text input with the app's animated filled surface                |
| `AppTopBar`                             | Screen `AppBar` with centered title, profile leading, actions         |
| `AppContainer`                          | Dashboard card with optional header row and tap target                |
| `AppSliverGroup`                        | Section header + sliver/box content inside a `CustomScrollView`       |
| `AppIconContainer`                      | Small filled icon surface (leading icons, status badges)              |
| `AppChipContainer` (+ `.outlined`)      | Compact rounded label/chip without selection/delete behavior          |
| `AppProfilePicture`                     | Circular avatar with initials/icon fallback when no image             |
| `AppEmptyState` / `AppEmptyStateSliver` | Centered empty/error state, with optional retry action                |
| `AppToast` (`AppToastType`)             | Semantic toast notifications — never call `ScaffoldMessenger` raw     |
| `AppResponsiveContainer`                | Center content and cap width (e.g. forms) on wide screens             |
| `RefreshWrapper` (+ `blocRefresh`)      | Pull-to-refresh wrapper for scrollable pages                          |
| `LogoutButton`                          | Logout action button with loading state, used in profile-type screens |

## Shared Extensions

All shared extensions live in `lib/core/internal/src/extensions/extensions.dart`. Always reach for these before writing one-off shimmer wrappers, spacing `SizedBox`es, date formatting, or `MediaQuery.of(context)` calls.

### `toShimmer()`

Use to show a loading shimmer over a single widget (typically a `Text` showing a value still loading from a BLoC). Pass `width`/`height` to constrain the shimmer's visual size independently of the widget's content size.

```dart
Text(user.name).toShimmer(context, isLoading: state.isLoading, width: 120, height: 16)
```

Wrap a whole `Container` directly with `.toShimmer()` (no width/height) to shimmer an entire block.

### `makeAnimate()` / `makeListAnimate()`

Use for entrance animations on a single widget or a list of widgets. Both share `AnimationType` (`fadeSlideUp`, `fadeSlideDown`, `fadeSlideLeft`, `fadeSlideRight`, `fadeOnly`, `scaleIn`).

```dart
card.makeAnimate(type: AnimationType.scaleIn);
children.makeListAnimate(type: AnimationType.fadeSlideLeft, interval: 80.ms);
```

Don't write raw `flutter_animate` chains directly — extend `AnimationType` instead if a new preset is needed.

### Date & Time Formatting

`DateAndTimeFormatterExtension` on `DateTime`. Time-only formats (`toHourMinuteFormat()`, `toHourMinuteSecondFormat()`) are locale-independent. Formats with a month or day name (`toDayMonthYearFormat(context)`, `toDayDateMonthYearFormat(context)`) require `BuildContext` — they read `Localizations.localeOf(context)` to match the app's active language (`en`/`id`).

```dart
Text(meeting.startTime.toDayDateMonthYearFormat(context))
// id: "Senin, 15 Juni 2026"   en: "Monday, 15 June 2026"
```

Never call `DateFormat(...)` directly in a widget — add a new method to the extension instead.

### Spacing

`num.h` / `num.w` for `SizedBox` spacing (`16.h`, `8.w`). `List<Widget>.separatedBy(separator)` to interleave a separator without a trailing one. Prefer these over manually-constructed `SizedBox`es.

### `MediaQueryExtension` on `BuildContext`

Use `context.screenWidth`, `context.screenHeight`, `context.viewInsets`, `context.padding` instead of `MediaQuery.of(context)` directly. These use the granular `MediaQuery.sizeOf`/`viewInsetsOf`/`paddingOf` APIs so widgets only rebuild when the specific field they depend on changes.

## Localization

ARB files in `lib/l10n/`. Use `AppLocalizations.of(context)!` in all widgets for visible text.

## Behavioral Guidelines

### Think Before Coding

Before implementing, state assumptions explicitly. If multiple interpretations exist, present them — don't pick silently. If a simpler approach exists, say so. If something is unclear, stop and ask.

### Simplicity First

Minimum code that solves the problem. No features beyond what was asked, no abstractions for single-use code, no error handling for impossible scenarios. If you write 200 lines and it could be 50, rewrite it.

### Surgical Changes

Touch only what you must. Don't improve adjacent code, comments, or formatting. Match existing style even if you'd do it differently. Mention unrelated dead code — don't delete it. Remove imports/variables/functions only when your changes made them unused.

Every changed line should trace directly to the user's request.

### Goal-Driven Execution

Transform tasks into verifiable goals before starting:

- "Add validation" → write tests for invalid inputs, then make them pass
- "Fix the bug" → write a test that reproduces it, then make it pass
- "Refactor X" → ensure tests pass before and after

For multi-step tasks, state a brief plan with a verify step for each.
