# Flutter Domain Repository Pattern

## Overview

Use this skill when creating an abstract repository class in the domain layer.
Trigger: user mentions "buat domain repository", "buat abstract repo", or after
entity creation when moving to the domain layer.

## Before Writing Any Code

Always ask the user first:

> "Repository ini perlu bisa ngapain aja? (fetch data, login/logout, remember me, dll)"

Based on the answer, refer to `flutter-data-interfaces` skill to decide which
interfaces to implement.

## File Location

```
lib/features/<feature_name>/domain/repositories/<feature_name>_repository.dart
```

## File Template

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/<feature_name>_entity/<feature_name>_entity.dart';

abstract class <FeatureName>Repository
    implements <Interface1><FeatureName><Entity>, <Interface2> {}
```

## Rules

- Always use `abstract class` (not `abstract interface class`)
- Always add the copyright header
- Only implement **Fetcher** interfaces
- NEVER implement `LocalManager` interfaces — local storage is data layer only
- If the required interface doesn't exist yet, create it first using
  the `flutter-data-interfaces` skill

## Examples

### Simple feature (single fetch)

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/sessions_entity/sessions_entity.dart';

abstract class SessionsRepository
    implements ItemFetcher<SessionsEntity> {}
```

### Feature with authentication

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/auth_response_entity/auth_response_entity.dart';

abstract class AuthRepository
    implements Authenticator<AuthResponseEntity>, RememberMeStorage {}
```

### Feature with complex fetching needs

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../entities/attendance_entity/attendance_entity.dart';

abstract class AttendanceRepository
    implements AttendanceFetcher<AttendanceEntity> {}
```

## Anti-patterns

- DO NOT add method implementations inside the abstract class
- DO NOT implement `LocalManager` interfaces here
- DO NOT skip the copyright header
