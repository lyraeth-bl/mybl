# Flutter Feature Folder Structure

## Overview

Use this skill every time a new feature is being created in a Flutter Clean Architecture project.
Trigger: user mentions "create new feature", "setup feature", "setup folder structure for feature" or mentions a specific feature name.

## Folder Structure

Create the following folder structure for every new feature:

```
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
└── <feature_name>_di.dart
```

## File: <feature_name>\_di.dart

Create this file at the root of the feature folder. Initial content is the
copyright header plus an empty DI function:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

void init{FeatureName}DI() {}
```

### Examples per feature:

- `auth` → file `auth_di.dart` → `void initAuthDI() {}`
- `sessions` → file `sessions_di.dart` → `void initSessionsDI() {}`
- `attendance` → file `attendance_di.dart` → `void initAttendanceDI() {}`

## Naming Convention

- Folder name: `snake_case` → `auth`, `sessions`, `attendance`
- DI function name: `camelCase` with prefix `init` and suffix `DI`
  → `init` + `{FeatureName}` + `DI`

## Anti-patterns

- DO NOT create any files other than `<feature_name>_di.dart` at this stage
- DO NOT put anything inside `_di.dart` other than the copyright header and
  empty void function
- DO NOT skip any folder shown in the required structure
