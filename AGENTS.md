# Flutter Clean Architecture Agent Guidelines

## Purpose

This file is the main coding guide for agents working in this repository. Read
it before writing or changing code. It merges the general Flutter rules from
`rules.md` with the project-specific Clean Architecture skills in
`.agents/skills`.

When a detailed pattern is needed, read the matching skill file in
`.agents/skills` before editing code.

## Project Stack

- **State management**: `flutter_bloc` + `freezed`
- **Functional programming**: `fpdart` (`Result`, `Either`, `Unit`)
- **Local storage**: `hive_ce` for regular data, `flutter_secure_storage` for
  sensitive data
- **HTTP**: custom `HTTPRequest` abstraction via `data_interfaces.dart`
- **Dependency injection**: `get_it`
- **Navigation**: `go_router`

## Absolute Rules

- Always add this copyright header at the top of standalone Dart files:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.
```

- Use `@freezed abstract class` for entities and models.
- Use `@freezed sealed class` for BLoC events and states.
- BLoC `part` files such as `*_event.dart` and `*_state.dart` follow the
  existing project style and start with `part of '<name>_bloc.dart';`.
- Run `dart run build_runner build --delete-conflicting-outputs` after creating
  or changing any file that uses `@freezed` or `fromJson`.
- Never put business logic in widgets or BLoCs. Business rules belong in use
  cases and repositories.
- Never skip the copyright header on standalone Dart files.
- Prefer existing project abstractions and patterns over adding new ones.
- Keep UI logic in widgets, app state in BLoCs, business flow in use cases, and
  IO/error handling in repositories and data sources.

## Agent Workflow

1. Read this `AGENTS.md`.
2. Identify the layer or task being changed.
3. Read the matching skill file from `.agents/skills`.
4. Inspect existing nearby code before creating new code.
5. Follow the feature creation order below.
6. Format, generate code, and analyze after edits.

Use these tools when available:

- `dart_format` for formatting Dart code.
- `dart_fix` for automatic Dart fixes.
- `analyze_files` for analyzer/lint checks.
- `pub_dev_search` before suggesting or adding new pub.dev dependencies.
- `pub` for adding/removing/upgrading dependencies.

## Feature Creation Order

When creating a new feature, always follow this order. Do not skip or reverse
steps.

1. Folder structure
2. Domain entity
3. Data interface, only if a new interface is needed
4. Domain repository
5. Use cases
6. Data models
7. Remote data source
8. Local data source, only if caching or local persistence is needed
9. Repository implementation
10. BLoC
11. Screen
12. DI registration

Each layer depends on the one before it.

## Skill Index

| Task | Skill file |
| --- | --- |
| Create feature folders | `.agents/skills/feature-folder-structure.md` |
| Create domain entity | `.agents/skills/flutter-entity.md` |
| Add or choose data interfaces | `.agents/skills/flutter-data-interfaces.md` |
| Create domain repository | `.agents/skills/flutter-domain-repository.md` |
| Create use cases | `.agents/skills/flutter-usecaes.md` |
| Create data models | `.agents/skills/flutter-model.md` |
| Create remote data source | `.agents/skills/flutter-remote-datasource.md` |
| Create local data source | `.agents/skills/flutter-local-datasource.md` |
| Create repository implementation | `.agents/skills/flutter-repository-impl.md` |
| Fill BLoC files | `.agents/skills/flutter-bloc.md` |
| Create screens | `.agents/skills/flutter-screen.md` |
| Fill DI registration | `.agents/skills/flutter-di.md` |
| Add Flutter animations | `.agents/skills/flutter-animating-apps/SKILL.md` |
| Fix Flutter layout issues | `.agents/skills/flutter-fix-layout-issues/SKILL.md` |
| Set up declarative routing | `.agents/skills/flutter-setup-declarative-routing/SKILL.md` |
| Set up localization | `.agents/skills/flutter-setup-localization/SKILL.md` |

Note: the use case skill file is currently named `flutter-usecaes.md`.

## Key Locations

```text
lib/
├── core/
│   ├── internal/src/interfaces/data_interfaces.dart
│   ├── internal/src/types.dart
│   ├── api_client/api_client.dart
│   ├── failure/failure.dart
│   └── di/get_it_constant.dart
└── features/
    └── <feature_name>/
        ├── <feature_name>_di.dart
        ├── data/
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        └── presentation/
            ├── bloc/
            ├── screens/
            └── widgets/
```

Some older or experimental files may not follow this layout exactly. For new
work, follow the standard feature layout used by `auth`, `user`, `attendance`,
`app_configuration`, and `sessions`.

## General Dart and Flutter Style

- Follow Effective Dart: https://dart.dev/effective-dart
- Keep code concise, declarative, and maintainable.
- Apply SOLID principles and prefer composition over inheritance.
- Prefer immutable data structures.
- Use meaningful, descriptive names. Avoid abbreviations.
- Use `PascalCase` for classes, `camelCase` for members/functions/enums, and
  `snake_case` for files.
- Keep functions short and focused.
- Add documentation comments to public APIs when the API is intended to be
  reused outside the immediate feature.
- Add comments only for non-obvious code.
- Avoid trailing comments.
- Use `async`/`await` where the layer pattern requires it.
- Use `Future` for single asynchronous operations and `Stream` for event
  sequences.
- Avoid `!` unless the value is guaranteed to be non-null.
- Use pattern matching and exhaustive `switch` expressions when they simplify
  code.
- Use `const` constructors and const widgets whenever possible.
- Do not run expensive work, network calls, or complex computation in
  `build()`.
- Use `ListView.builder` or slivers for long lists.
- Use small private `Widget` classes instead of private helper methods that
  return widgets.
- Use `logging` instead of `print`.

## Engineering Principles

- DRY (Don't Repeat Yourself): eliminate duplicated logic by extracting shared
  utilities and modules.
- Separation of Concerns: each module should handle one distinct responsibility.
- Single Responsibility Principle (SRP): every class, module, function, and file
  should have exactly one reason to change.
- Clear Abstractions and Contracts: expose intent through small, stable
  interfaces and hide implementation details.
- Low Coupling, High Cohesion: keep modules self-contained and minimize
  cross-dependencies.
- Scalability and Statelessness: design components to scale horizontally and
  prefer stateless services when possible.
- Observability and Testability: build in logging, metrics, and tracing, and
  ensure components can be unit and integration tested.
- KISS (Keep It Simple, Sir): keep solutions as simple as possible.
- YAGNI (You're Not Gonna Need It): avoid speculative complexity or
  over-engineering.

## Dependency Rules

- Do not add a third-party dependency unless the existing stack cannot handle
  the requirement cleanly.
- When adding dependencies, prefer `pub` tooling if available.
- Explain the benefit of any new dependency.
- The project already standardizes on `flutter_bloc`, `freezed`, `fpdart`,
  `hive_ce`, `flutter_secure_storage`, `get_it`, and `go_router`.

## Routing Rules

- Use `go_router` for declarative navigation, deep linking, and web-compatible
  routing.
- Configure auth redirects through `go_router.redirect` when needed.
- Use `Navigator` only for temporary views such as dialogs or short-lived flows
  that do not need deep links.

## Feature Folder Pattern

Read `.agents/skills/feature-folder-structure.md`.

Create this structure for each feature:

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
│   ├── screens/
│   └── widgets/
└── di.dart
```

The initial DI file contains the copyright header and an empty DI function:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

void init<FeatureName>DI() {}
```

Do not create other files during the folder-structure step. Do not add anything
else to the DI function during this step.

## Entity Pattern

Read `.agents/skills/flutter-entity.md`.

- Ask for API response or DB fields before writing an entity.
- Prefer API response fields when both API and DB fields exist.
- Location:
  `lib/features/<feature_name>/domain/entities/<entity_name>/<entity_name>.dart`
- Use `@freezed abstract class`.
- Do not add `fromJson` or `toJson` in domain entities.
- Do not put IO, validation flow, or application workflow logic inside
  entities.
- Simple derived getters are allowed on value objects/entities when they are
  deterministic and only use the entity's own fields, as in
  `AttendanceSummary`.

Template:

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

## Data Interface Pattern

Read `.agents/skills/flutter-data-interfaces.md`.

All shared interfaces live in:

```text
lib/core/internal/src/interfaces/data_interfaces.dart
```

Available base interfaces:

| Interface                   | Use when                               |
|-----------------------------|----------------------------------------|
| `ItemFetcher<T>`            | Fetch one item from API/cache          |
| `ListFetcher<T>`            | Fetch a list from API/cache            |
| `CacheStorage<T>`           | Save/read one local data type          |
| `ListCacheStorage<T>`       | Save/read list local data type          |
| `Authenticator<T>`          | Login/logout                           |
| `RememberMeStorage`         | Persist NIS for remember me            |
| `TokenStorage`              | Manage access token                    |
| `LocalStorageManager`       | Manage local database boxes            |
| `AttendanceFetcher<T>`      | Fetch daily/monthly attendance         |
| `AttendanceLocalManager<T>` | Cache daily/monthly attendance in Hive |

Before creating a new interface, ask what the repository must do. Reuse an
existing interface when it covers the need.
Always check the bottom of `data_interfaces.dart` for project-specific
interfaces before adding another one.

Rules:

- New interfaces use `abstract interface class`.
- Add new interfaces at the bottom of `data_interfaces.dart`.
- Fetch methods include `[bool forceRefresh = false]` when cache bypass matters.
- Fetcher interfaces may be implemented by domain repositories.
- Local manager interfaces are data-layer only and must not be implemented by
  domain repositories.

## Domain Repository Pattern

Read `.agents/skills/flutter-domain-repository.md`.

- Ask what repository actions are needed before writing.
- Location:
  `lib/features/<feature_name>/domain/repositories/<feature_name>_repository.dart`
- Use `abstract class`, not `abstract interface class`.
- Implement fetcher/auth/storage contracts that belong at the repository level.
- Never implement local manager interfaces in the domain repository.
- Do not add method implementations.

Template:

```dart
import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/<entity_name>/<entity_name>.dart';

abstract class <FeatureName>Repository
    implements <InterfaceName><<EntityName>> {}
```

## Use Case Pattern

Read `.agents/skills/flutter-usecaes.md`.

- One repository method gets one use case class and one file.
- Location:
  `lib/features/<feature_name>/domain/usecases/<method_name>_use_case.dart`
- Use `call()` only. Do not create custom method names.
- Do not use `async`/`await`; forward directly to the repository.
- Use direct parameters for simple methods with 3 or fewer input fields.
- Create a Params entity when more than 3 fields are needed, when a request
  object already exists, or when the input is a cohesive form/request value such
  as `LoginParams`.

Template:

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

If a Params entity is created, also create the matching request model and run
build runner.

## Model Pattern

Read `.agents/skills/flutter-model.md`.

- Ask for API response JSON before writing a model.
- Location:
  `lib/features/<feature_name>/data/models/<model_name>/<model_name>.dart`
- Models use `@freezed abstract class`.
- Base models mirror entities and include `fromJson` plus `toEntity()`.
- Response/DTO models wrap full API responses and include `fromJson` only.
- Do not add `toEntity()` to response/DTO models.
- Prefer explicit `@JsonKey(name: '...')` on API-backed model fields. Existing
  models use it even for identical names such as `id`, `nis`, and `status`.
- Use `@Default(value)` when API data can be null but Dart needs a default.
- Do not manually write `toJson()`.

Base model template:

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

## Remote Data Source Pattern

Read `.agents/skills/flutter-remote-datasource.md`.

- Ask required methods, HTTP methods, query params, and request bodies first.
- Location:
  `lib/features/<feature_name>/data/datasources/<feature_name>_remote_data_source.dart`
- Each remote data source file has an abstract contract and an implementation.
- Inject `HTTPRequest`, never concrete HTTP clients.
- Return response/DTO models, never entities or raw maps.
- Use `async`/`await`.
- For POST/PUT, call `.toJson()` on request models.
- For GET query params, define `final Map<String, dynamic> query = {...}` first.
- Use `ApiEndpoints.someName` as placeholder when the exact endpoint is unknown.
- For `Unit` methods, return `unit` after the request completes.
- Do not handle repository-level business errors here.

## Local Data Source Pattern

Read `.agents/skills/flutter-local-datasource.md`.

- Ask what data is stored and whether it is sensitive.
- Location:
  `lib/features/<feature_name>/data/datasources/<feature_name>_local_data_source.dart`
- Use `FlutterSecureStorage` for sensitive data such as tokens or credentials.
- Use `HiveInterface` for regular model/cache data.
- Always implement `LocalManager`, `CacheStorage`, or another interface from
  `data_interfaces.dart`.
- For Hive reads, call `Map<String, dynamic>.from(rawData)` before `fromJson`.
- For Hive writes, save `model.toJson()`.
- For list data in Hive, cast to `List<dynamic>` and map each item through
  `fromJson`.
- Return `unit` after successful writes.
- Use private helper methods for dynamic cache keys.

## Repository Implementation Pattern

Read `.agents/skills/flutter-repository-impl.md`.

- Location:
  `lib/features/<feature_name>/data/repositories/<feature_name>_repository_impl.dart`
- Always implement the domain repository.
- Remote calls use `try/catch` and wrap errors with `Failure.fromError(e, st)`.
- Local-only methods delegate directly and do not need `try/catch`.
- Always convert models to entities before returning.
- Do not throw raw exceptions from repository implementations.
- Add `forceRefresh` only when the method has cache behavior.

Cache flow:

1. If `forceRefresh` is false, check local data first.
2. Return local data immediately when available.
3. Otherwise fetch remote data.
4. Save remote result locally.
5. Return the entity.

Remote-only flow:

1. Build request model if needed.
2. Call remote data source.
3. Convert response/model to entity.
4. Return `right(entity)` or `left(Failure.fromError(e, st))`.

Local-only flow:

1. Delegate to local data source.
2. Return local result directly.

## BLoC Pattern

Read `.agents/skills/flutter-bloc.md`.

- BLoC consists of three files: `_bloc.dart`, `_event.dart`, `_state.dart`.
- Ask what the BLoC handles, required events, and whether fetched data can be
  null or empty.
- Initial state is always `const <Name>State.initial()`.
- Emit `loading()` before async operations.
- Handle `Result` with `result.match()`, not `fold()` or manual `if/else`.
- Use `return result.match(...)` for simple single-expression handlers. Calling
  `result.match(...)` without `return` is acceptable when a callback needs a
  block to derive UI-ready state, as in `MonthlyAttendanceBloc`.
- Do not emit after `result.match()` outside the callbacks.
- State must have at least `initial`, `loading`, and `failure`.
- Event and state classes use `@freezed sealed class`.
- Event and state part files start with `part of '<name>_bloc.dart';` to match
  the existing project files.
- Private handlers are named `_on<EventName>`.
- Handler event parameters use the private generated event type.
- Put presentation-specific transformations in private static helper methods
  when needed. Business rules that must be shared belong in domain.
- Do not put UI logic in BLoCs.

BLoC file structure:

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

## Screen Pattern

Read `.agents/skills/flutter-screen.md`.

- Location:
  `lib/features/<feature_name>/presentation/screens/<feature_name>_screen.dart`
- Use two layers:
  - Outer `Screen`: `StatelessWidget`, injects BLoCs only.
  - Inner private view: contains UI.
- Match existing screen style from `profile_screen.dart` and
  `attendance_screen.dart`.
- Use `Scaffold` as the page root.
- Prefer `CustomScrollView` with slivers for scrollable screens.
- Prefer `SliverAppBar.medium` for scrollable page headers.
- Use `BouncingScrollPhysics` for main scroll views.
- Use `Theme.of(context).colorScheme` and `Theme.of(context).textTheme`
  instead of hard-coded colors and text styles.
- Use `AppLocalizations.of(context)!` for visible text.
- Reuse shared UI from `core/widgets/` before creating new primitives.
- Reuse feature widgets from `presentation/widgets/` for feature-specific UI.
- Use `BlocProvider` or `MultiBlocProvider`.
- Use `di<BlocName>()` only inside `BlocProvider.create`.
- Trigger initial events in `initState` with
  `WidgetsBinding.instance.addPostFrameCallback`.
- Exception: app-wide global BLoCs may chain `..add()` in `create` when loading
  must begin immediately.
- Use `RefreshWrapper` and `blocRefresh` for pull-to-refresh pages.
- Use `RepaintBoundary` around expensive visual sections such as charts,
  calendars, or dense custom containers.
- Use `BlocBuilder` for UI rebuilds.
- Use `buildWhen` when only part of state matters.
- Use `BlocSelector` when only one value is needed.
- Use `BlocListener` for side effects such as snackbars, navigation, and
  triggering another BLoC.
- Use `maybeWhen` and `whenOrNull`; avoid state type `if/else`.
- Use records for grouped derived state when that keeps `buildWhen` clear.
- Use existing shimmer/loading and animation extensions when surrounding
  feature screens already use them.
- Keep common spacing close to existing screens: `16` for horizontal page
  padding, `24` for larger vertical sections, and `SizedBox` for small gaps.
- Keep private widgets in the screen file unless they are reusable across
  features. Reusable widgets belong in `core/widgets/`; widgets reusable inside
  one feature belong in that feature's `presentation/widgets/`.

## Dependency Injection Pattern

Read `.agents/skills/flutter-di.md`.

- Location: `lib/features/<feature_name>/di.dart`
- Preferred order for new DI files is from lowest layer to highest:
  1. Local data source
  2. Remote data source
  3. Repository
  4. Use cases
  5. BLoC/Cubit
- Use `registerLazySingleton` for data sources, repositories, use cases, and
  global/shared BLoCs.
- Use `registerFactory` for per-screen BLoCs/Cubits.
- Global BLoCs manage app-wide state that must persist across screens, such as
  `SessionBloc` or `AppConfigurationBloc`.
- `UserBloc` is currently registered as a lazy singleton because user state is
  shared by profile-related screens.
- Existing DI files have mixed registration ordering. Do not reorder existing DI
  only for style; preserve the local file style unless it causes a real bug.
- Use pre-registered infrastructure dependencies through `di<>`:
  - `di<HiveInterface>()`
  - `di<FlutterSecureStorage>()`
  - `di<HTTPRequest>()`
- Do not register infrastructure dependencies inside feature DI.

## Decision Guide

### Which interface should a domain repository use?

Read `.agents/skills/flutter-data-interfaces.md`, then determine what the
repository needs to do. Ask the user when the behavior is unclear.

### When should a new interface be added?

Only when existing interfaces do not cover the feature need.

### Should a BLoC use `registerLazySingleton` or `registerFactory`?

- Global/app-wide BLoC: `registerLazySingleton`
- Per-screen BLoC: `registerFactory`

### When should a use case use a Params class?

Only when the use case needs more than 3 input fields.

### When should a feature have a local data source?

Only when the feature needs local cache or persistence.

- Sensitive data: `FlutterSecureStorage`
- Regular data: `HiveInterface`

## Verification

After edits:

1. Run build runner if `@freezed` or `fromJson` files changed.
2. Run Dart formatting.
3. Run Dart analyzer.
4. Run focused tests when tests exist for the changed area.

Preferred commands:

```bash
dart run build_runner build --delete-conflicting-outputs
dart format .
dart analyze
```
