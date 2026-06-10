# Flutter BLoC Pattern

## Overview

Use this skill when filling in the contents of BLoC files in the presentation layer.
Trigger: user mentions "isi bloc", "buat bloc", or after use case creation.

Note: The 3 files (`_bloc.dart`, `_event.dart`, `_state.dart`) are already created
by the plugin. This skill only covers filling in their contents.

For simple local state with no event stream, a `Cubit` is allowed. Follow the
same `freezed` state style used by `RememberMeCubit`.

## File Location

### Single BLoC per feature

```
lib/features/<feature_name>/presentation/bloc/
├── <name>_bloc.dart
├── <name>_event.dart
└── <name>_state.dart
```

### Multiple BLoCs in one feature

```
lib/features/<feature_name>/presentation/bloc/
├── <bloc_a_name>/
│   ├── <bloc_a_name>_bloc.dart
│   ├── <bloc_a_name>_event.dart
│   └── <bloc_a_name>_state.dart
├── <bloc_b_name>/
│   ├── <bloc_b_name>_bloc.dart
│   ├── <bloc_b_name>_event.dart
│   └── <bloc_b_name>_state.dart
```

## Before Writing Any Code

Ask the user:

1. "BLoC ini handle apa aja? (fetch data, submit form, manage session, dll)"
2. "Ada berapa aksi/event yang dibutuhin?"
3. "Kalau fetch data, hasilnya bisa null/kosong atau selalu ada?"

## Structure: Always 3 Files

### File 1: \_bloc.dart

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '<use_case_import>';
import '<entity_import>';
import '<failure_import>';

part '<name>_bloc.freezed.dart';
part '<name>_event.dart';
part '<name>_state.dart';

class <Name>Bloc extends Bloc<<Name>Event, <Name>State> {
  <Name>Bloc(this._<useCase>) : super(const <Name>State.initial()) {
    on<_<EventName>>(_on<EventName>);
  }

  final <UseCase> _<useCase>;

  Future<void> _on<EventName>(
    _<EventName> event,
    Emitter<<Name>State> emit,
  ) async {
    emit(const <Name>State.loading());

    final result = await _<useCase>(/* params */);

    return result.match(
      (failure) => emit(<Name>State.failure(failure)),
      (data) => emit(<Name>State.success(/* data */)),
    );
  }
}
```

### File 2: \_event.dart

```dart
part of '<name>_bloc.dart';

@freezed
sealed class <Name>Event with _$<Name>Event {
  const factory <Name>Event.<eventName>(/* params */) = _<EventName>;
}
```

### File 3: \_state.dart

```dart
part of '<name>_bloc.dart';

@freezed
sealed class <Name>State with _$<Name>State {
  const factory <Name>State.initial() = _Initial;
  const factory <Name>State.loading() = _Loading;
  const factory <Name>State.success(/* data */) = _Success;
  const factory <Name>State.failure(Failure failure) = _Failure;
}
```

## Rules

- ALWAYS start with `const <Name>State.initial()` as the initial state
- ALWAYS emit `loading()` before any async operation
- ALWAYS use `result.match()` for handling `fpdart` Result — never use `fold` or `if/else`
- Use `return result.match(...)` when both callbacks are single-expression
  emits. If the success path needs a block to derive UI-ready data, calling
  `result.match(...)` without `return` is acceptable, as in
  `MonthlyAttendanceBloc`
- NEVER use `emit()` after `result.match()` outside of the match callbacks
- State ALWAYS has at minimum: `initial`, `loading`, `failure`
- Event and State classes ALWAYS use `@freezed sealed class`
- Event and State files ALWAYS start with `part of '<name>_bloc.dart';`
- Private event handlers ALWAYS named `_on<EventName>`
- Private handler parameters ALWAYS use the private generated class (e.g. `_FetchStudentRequested`)
- Presentation-specific derived data may be prepared in private static helpers
  inside the BLoC when it exists only to support UI state, for example
  monthly attendance maps and summaries. Do not put repository/API/storage logic
  here

## State Design Guide

### Standard fetch (result always exists)

```dart
const factory <Name>State.success({required <Entity> data}) = _Success;
```

### Fetch with nullable result (data might not exist)

Add a dedicated empty state instead of nullable success:

```dart
const factory <Name>State.success({required <Entity> data}) = _Success;
const factory <Name>State.empty() = _Empty;
```

### Multi-action (different success outcomes)

Use named success states:

```dart
const factory <Name>State.successLogin({required String accessToken}) = _SuccessLogin;
const factory <Name>State.successLogout() = _SuccessLogout;
```

### State with carried data (e.g. pagination, navigation)

Carry data in loading too so UI doesn't lose context:

```dart
const factory <Name>State.loading({required int month, required int year}) = _Loading;
const factory <Name>State.success({
  required int month,
  required int year,
  required List<<Entity>> data,
}) = _Success;
```

## Event Design Guide

### Simple trigger (no params)

```dart
const factory <Name>Event.someRequested() = _SomeRequested;
```

### With optional forceRefresh

```dart
const factory <Name>Event.someRequested([
  @Default(false) bool forceRefresh,
]) = _SomeRequested;
```

### With required params

```dart
const factory <Name>Event.someRequested({
  required int month,
  required int year,
  @Default(false) bool forceRefresh,
}) = _SomeRequested;
```

## Special Patterns

### Event triggering another event (e.g. prev/next navigation)

```dart
Future<void> _onPreviousRequested(
  _PreviousRequested event,
  Emitter<<Name>State> emit,
) async {
  // compute new params from current state
  add(<Name>Event.mainEvent(/* new params */));
}
```

### Helper methods in BLoC (static preferred)

If the BLoC needs data transformation, add private static methods:

```dart
static <ReturnType> _someHelper(<params>) {
  // transformation logic here
}
```

Use this for UI-state transformations only. For business rules that must be
shared or tested independently, move the logic to domain use cases or entities.

### Cubit for local UI state

Use Cubit when there are no discrete event types and the state is a simple local
value object, for example Remember Me checkbox + saved NIS:

```dart
class RememberMeCubit extends Cubit<RememberMeState> {
  RememberMeCubit(this._readNisUseCase, this._saveNisUseCase)
      : super(const RememberMeState());

  final ReadNisUseCase _readNisUseCase;
  final SaveNisUseCase _saveNisUseCase;
}
```

### Multiple use cases in one BLoC

Inject all use cases in the constructor:

```dart
<Name>Bloc(
  this._useCaseA,
  this._useCaseB,
  this._useCaseC,
) : super(const <Name>State.initial()) {
  on<_EventA>(_onEventA);
  on<_EventB>(_onEventB);
}

final UseCaseA _useCaseA;
final UseCaseB _useCaseB;
final UseCaseC _useCaseC;
```

## Examples

### Simple fetch (UserBloc)

**\_bloc.dart**

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/student_entity/student_entity.dart';
import '../../domain/usecases/fetch_student_use_case.dart';

part 'user_bloc.freezed.dart';
part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this._fetchStudentUseCase) : super(const UserState.initial()) {
    on<_FetchStudentRequested>(_onFetchStudentRequested);
  }

  final FetchStudentUseCase _fetchStudentUseCase;

  Future<void> _onFetchStudentRequested(
    _FetchStudentRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserState.loading());

    final result = await _fetchStudentUseCase(event.forceRefresh);

    return result.match(
      (failure) => emit(UserState.failure(failure)),
      (data) => emit(UserState.success(student: data)),
    );
  }
}
```

**\_event.dart**

```dart
part of 'user_bloc.dart';

@freezed
sealed class UserEvent with _$UserEvent {
  const factory UserEvent.fetchStudentRequested([
    @Default(false) bool forceRefresh,
  ]) = _FetchStudentRequested;
}
```

**\_state.dart**

```dart
part of 'user_bloc.dart';

@freezed
sealed class UserState with _$UserState {
  const factory UserState.initial() = _Initial;
  const factory UserState.loading() = _Loading;
  const factory UserState.success({required StudentEntity student}) = _Success;
  const factory UserState.failure(Failure failure) = _Failure;
}
```

### Fetch with empty state (DailyAttendanceBloc)

**\_state.dart**

```dart
part of 'daily_attendance_bloc.dart';

@freezed
sealed class DailyAttendanceState with _$DailyAttendanceState {
  const factory DailyAttendanceState.initial() = _Initial;
  const factory DailyAttendanceState.loading() = _Loading;
  const factory DailyAttendanceState.success({
    required AttendanceEntity dailyAttendance,
  }) = _Success;
  const factory DailyAttendanceState.emptyAttendance() = _EmptyAttendance;
  const factory DailyAttendanceState.failure(Failure failure) = _Failure;
}
```

**\_bloc.dart (handler)**

```dart
return result.match(
  (failure) => emit(DailyAttendanceState.failure(failure)),
  (data) {
    if (data == null) {
      emit(const DailyAttendanceState.emptyAttendance());
      return;
    }
    emit(DailyAttendanceState.success(dailyAttendance: data));
  },
);
```

## After Filling BLoC Files

Always run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Anti-patterns

- DO NOT use `fold()` — always use `result.match()`
- DO NOT emit after `result.match()` outside the callbacks
- DO NOT skip `emit(loading())` before async operations
- DO NOT use `abstract class` for Event/State — always `sealed class`
- DO NOT forget `part` and `part of` declarations
- DO NOT put UI logic inside the BLoC
- DO NOT skip the copyright header on `_bloc.dart`
