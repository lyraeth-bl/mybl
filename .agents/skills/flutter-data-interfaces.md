# Flutter Data Interfaces

## Overview

Use this skill when a new interface needs to be added to `data_interfaces.dart`,
or when deciding which existing interface to use for a new feature.
Trigger: user mentions "tambah interface", "bikin interface baru", or when creating
a domain repository that requires an interface that doesn't exist yet.

## File Location

All interfaces live in one single file:

```
lib/core/internal/src/interfaces/data_interfaces.dart
```

Never create interface files elsewhere.

## Available Base Interfaces

| Interface             | Use when                                        |
| --------------------- | ----------------------------------------------- |
| `ItemFetcher<T>`      | Need to fetch a single data from API            |
| `ListFetcher<T>`      | Need to fetch a list of data from API           |
| `CacheStorage<T>`     | Need to save/read a single type of data locally |
| `Authenticator<T>`    | Need login/logout functionality                 |
| `RememberMeStorage`   | Need to persist NIS for "remember me" feature   |
| `TokenStorage`        | Need to manage access token                     |
| `LocalStorageManager` | Need to manage local database boxes             |

## Existing Project-Specific Interfaces

| Interface                   | Use when                                               |
| --------------------------- | ------------------------------------------------------ |
| `AttendanceFetcher<T>`      | Need daily and monthly attendance fetch operations     |
| `AttendanceLocalManager<T>` | Need daily/monthly attendance cache operations in Hive |

Always check the bottom of `data_interfaces.dart` for feature-specific
interfaces before creating a new one.

## Decision: Use Existing vs Create New

Before writing any interface, ask the user:

> "Apa aja yang perlu bisa dilakuin repository ini? (fetch data, cache, login, dll)"

Then decide:

- If the need maps directly to an existing interface → use it as-is
- If the need is a variation of an existing interface but with more operations → create a new interface
- If the need is entirely new → create a new interface

## Rules for Creating New Interfaces

- Always use `abstract interface class`
- Place the new interface at the bottom of `data_interfaces.dart`
- Name it descriptively based on its responsibility:
  - Fetching data → `<Feature>Fetcher<T>`
  - Managing local storage → `<Feature>LocalManager<T>`
- NEVER create a `LocalManager` interface and implement it in the domain repository.
  Local management is strictly a data layer concern.

## Interface Categories

### Fetcher interfaces → domain repository concern

Interfaces that deal with fetching data (from API or cache) can be implemented
by domain repositories.

### LocalManager interfaces → data layer concern only

Interfaces that deal with saving/reading from local storage are NEVER implemented
by domain repositories. They are only used inside `DataSource` classes in the data layer.

## Rules for Fetcher Interfaces

- Always include `[bool forceRefresh = false]` as an optional parameter on every fetch method
- The `forceRefresh` flag is used to bypass local storage and force fetch from the API

## Example: Creating a New Fetcher Interface

Shape the methods based on what the user says the feature needs to fetch.
Do NOT assume the method signatures — always ask the user first.

```dart
abstract interface class Fetcher {
  // Methods are defined based on user's requirements
  // Always include [bool forceRefresh = false] on every fetch method
  Future<Result> fetchSomething([bool forceRefresh = false]);
}
```

## Example: Creating a New LocalManager Interface

Shape the methods based on what the user says the feature needs to store locally.
Do NOT assume the method signatures — always ask the user first.

```dart
abstract interface class LocalManager<T> {
  // Methods are defined based on user's requirements
  Future<Unit> saveData(T data);

  T? readData();
}
```

If the following data is a List, make like this.

```dart
abstract interface class LocalManager<List<T>> {
  // Methods are defined based on user's requirements
  Future<Unit> saveData(List<T> listData);

  List<T>? readData();
}
```

## Anti-patterns

- DO NOT create interface files outside `data_interfaces.dart`
- DO NOT implement `LocalManager` interfaces in domain repositories
- DO NOT create a new interface if an existing one already covers the need
- DO NOT assume method signatures — always ask the user about the feature's needs first
