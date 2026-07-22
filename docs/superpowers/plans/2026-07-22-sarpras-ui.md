# Sarpras UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give students a screen to submit, track, correct, and withdraw facility-use requests (izin sarpras).

**Architecture:** Clean Architecture per feature. `SarprasBloc` fetches the list; each write action has its own Cubit so a form submission never blanks the list behind it. Detail and form open as `CupertinoSheetRoute` pages wired through go_router.

**Tech Stack:** Flutter 3.41.8, `flutter_bloc`, `freezed`, `fpdart`, `get_it`, `go_router`, `mocktail`, `flutter_test`.

Spec: `docs/superpowers/specs/2026-07-22-sarpras-ui-design.md`

## Global Constraints

- Copyright header on every standalone Dart file (NOT on `part of` files):
  ```dart
  // Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
  // Use of this source code is governed by a MIT License
  // that can be found in the LICENSE file.
  ```
- `@freezed abstract class` for entities/models; `@freezed sealed class` for BLoC/Cubit states.
- Run `dart run build_runner build --delete-conflicting-outputs` after any `@freezed` change.
- Lines ≤ 80 characters. No `print()`. No hardcoded colours or text styles.
- All visible text via `AppLocalizations.of(context)!`.
- Colours via `Theme.of(context).colorScheme` or `AppColors.of(context)`.
- Spacing via `num.h` / `num.w`; separators via `List<Widget>.separatedBy()`.
- Never call `DateFormat(...)` in a widget — use the extensions on `DateTime`.
- Status string literals are exactly `'Menunggu'`, `'Disetujui'`, `'Ditolak'`.
- Student role only. No parent route, no parent menu entry.
- Before every commit: `dart format .` then `flutter analyze` must be clean.

---

### Task 1: `Sarpras.isCancelable`

**Files:**
- Modify: `lib/features/sarpras/domain/entities/sarpras/sarpras.dart`
- Test: `test/features/sarpras/domain/sarpras_rules_test.dart` (create)

**Interfaces:**
- Consumes: nothing.
- Produces: `bool Sarpras.isCancelable` — true only when `status == 'Menunggu'`.

- [ ] **Step 1: Write the failing test**

Create `test/features/sarpras/domain/sarpras_rules_test.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras/sarpras.dart';

Sarpras _sarpras({required String status}) => Sarpras(
  id: 1,
  unit: 'SMAKT',
  nis: '24251026',
  tanggalKegiatan: DateTime(2026, 7, 23),
  namaKegiatan: 'Meeting IT',
  jumlahSiswaDalamKegiatan: '5',
  nipGuruPembimbing: '20250602',
  waktuKegiatan: '12.00 - 15.00',
  status: status,
);

void main() {
  test('isCancelable is true only while the request is pending', () {
    expect(_sarpras(status: 'Menunggu').isCancelable, isTrue);
    expect(_sarpras(status: 'Disetujui').isCancelable, isFalse);
    expect(_sarpras(status: 'Ditolak').isCancelable, isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sarpras/domain/sarpras_rules_test.dart`
Expected: FAIL — "The getter 'isCancelable' isn't defined for the type 'Sarpras'".

- [ ] **Step 3: Add the getter**

In `lib/features/sarpras/domain/entities/sarpras/sarpras.dart`, add a private
const constructor and the getter inside the class body. Freezed requires the
`const Sarpras._();` line before any custom getter:

```dart
@freezed
abstract class Sarpras with _$Sarpras {
  const Sarpras._();

  const factory Sarpras({
    required int id,
    required String unit,
    required String nis,
    required DateTime tanggalKegiatan,
    required String namaKegiatan,
    required String jumlahSiswaDalamKegiatan,
    required String nipGuruPembimbing,
    required String waktuKegiatan,
    required String status,
    SarprasMetadata? metadata,
  }) = _Sarpras;

  /// Whether the request can still be edited or withdrawn.
  ///
  /// The backend rejects changes to processed requests with a 422, so this
  /// mirrors that rule client-side.
  bool get isCancelable => status == 'Menunggu';
}
```

- [ ] **Step 4: Regenerate and run the test**

Run: `dart run build_runner build --delete-conflicting-outputs`
Then: `flutter test test/features/sarpras/domain/sarpras_rules_test.dart`
Expected: PASS, 1 test.

- [ ] **Step 5: Commit**

```bash
dart format . && flutter analyze
git add lib/features/sarpras/domain/entities/sarpras/sarpras.dart \
        test/features/sarpras/domain/sarpras_rules_test.dart
git commit -m "feat(sarpras): add isCancelable rule to entity"
```

---

### Task 2: `DetailSarprasCubit`

**Files:**
- Create: `lib/features/sarpras/presentation/cubit/detail_sarpras_cubit.dart`
- Create: `lib/features/sarpras/presentation/cubit/detail_sarpras_state.dart`
- Modify: `lib/features/sarpras/sarpras_di.dart`
- Test: `test/features/sarpras/presentation/detail_sarpras_cubit_test.dart` (create)

**Interfaces:**
- Consumes: `FetchDetailSarprasUseCase({required int sarprasId})` returning `Future<Result<Sarpras>>`.
- Produces:
  - `DetailSarprasCubit(FetchDetailSarprasUseCase)` with
    `Future<void> fetchDetail({required int sarprasId})`
  - `DetailSarprasState` — `initial()`, `loading()`,
    `success({required Sarpras sarpras})`, `failure(Failure failure)`

- [ ] **Step 1: Write the failing test**

Create `test/features/sarpras/presentation/detail_sarpras_cubit_test.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/core/failure/failure.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras/sarpras.dart';
import 'package:my_bl/features/sarpras/domain/repositories/sarpras_repository.dart';
import 'package:my_bl/features/sarpras/domain/usecases/fetch_detail_sarpras_use_case.dart';
import 'package:my_bl/features/sarpras/presentation/cubit/detail_sarpras_cubit.dart';

class _MockSarprasRepository extends Mock implements SarprasRepository {}

final Sarpras _sarpras = Sarpras(
  id: 4,
  unit: 'SMAKT',
  nis: '24251026',
  tanggalKegiatan: DateTime(2026, 7, 23),
  namaKegiatan: 'Meeting IT',
  jumlahSiswaDalamKegiatan: '5',
  nipGuruPembimbing: '20250602',
  waktuKegiatan: '12.00 - 15.00',
  status: 'Menunggu',
);

void main() {
  test('emits loading then success', () async {
    final repository = _MockSarprasRepository();
    when(
      () => repository.fetchDetailSarpras(sarprasId: 4),
    ).thenAnswer((_) async => right(_sarpras));

    final cubit = DetailSarprasCubit(FetchDetailSarprasUseCase(repository));
    addTearDown(cubit.close);

    final states = <DetailSarprasState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.fetchDetail(sarprasId: 4);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(states, [
      const DetailSarprasState.loading(),
      DetailSarprasState.success(sarpras: _sarpras),
    ]);
  });

  test('emits loading then failure', () async {
    final repository = _MockSarprasRepository();
    const failure = Failure.unexpected(errorMessage: 'boom');
    when(
      () => repository.fetchDetailSarpras(sarprasId: 9),
    ).thenAnswer((_) async => left(failure));

    final cubit = DetailSarprasCubit(FetchDetailSarprasUseCase(repository));
    addTearDown(cubit.close);

    final states = <DetailSarprasState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.fetchDetail(sarprasId: 9);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(states, [
      const DetailSarprasState.loading(),
      const DetailSarprasState.failure(failure),
    ]);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sarpras/presentation/detail_sarpras_cubit_test.dart`
Expected: FAIL — target of URI doesn't exist: `detail_sarpras_cubit.dart`.

- [ ] **Step 3: Write the state**

Create `lib/features/sarpras/presentation/cubit/detail_sarpras_state.dart`:

```dart
part of 'detail_sarpras_cubit.dart';

@freezed
sealed class DetailSarprasState with _$DetailSarprasState {
  const factory DetailSarprasState.initial() = _Initial;
  const factory DetailSarprasState.loading() = _Loading;
  const factory DetailSarprasState.success({required Sarpras sarpras}) =
      _Success;
  const factory DetailSarprasState.failure(Failure failure) = _Failure;
}
```

- [ ] **Step 4: Write the cubit**

Create `lib/features/sarpras/presentation/cubit/detail_sarpras_cubit.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/sarpras/sarpras.dart';
import '../../domain/usecases/fetch_detail_sarpras_use_case.dart';

part 'detail_sarpras_state.dart';
part 'detail_sarpras_cubit.freezed.dart';

class DetailSarprasCubit extends Cubit<DetailSarprasState> {
  DetailSarprasCubit(this._fetchDetailSarprasUseCase)
    : super(const .initial());

  final FetchDetailSarprasUseCase _fetchDetailSarprasUseCase;

  Future<void> fetchDetail({required int sarprasId}) async {
    emit(const .loading());

    final result = await _fetchDetailSarprasUseCase(sarprasId: sarprasId);

    return result.match(
      (f) => emit(.failure(f)),
      (r) => emit(.success(sarpras: r)),
    );
  }
}
```

- [ ] **Step 5: Register in DI**

In `lib/features/sarpras/sarpras_di.dart`, add the import beside the other
cubit imports and register after `UpdateSarprasCubit`:

```dart
import 'presentation/cubit/detail_sarpras_cubit.dart';
```

```dart
  di.registerFactory<DetailSarprasCubit>(
    () => DetailSarprasCubit(di<FetchDetailSarprasUseCase>()),
  );
```

- [ ] **Step 6: Regenerate and run the test**

Run: `dart run build_runner build --delete-conflicting-outputs`
Then: `flutter test test/features/sarpras/presentation/detail_sarpras_cubit_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 7: Commit**

```bash
dart format . && flutter analyze
git add lib/features/sarpras test/features/sarpras
git commit -m "feat(sarpras): add DetailSarprasCubit"
```

---

### Task 3: `SarprasTeacherCandidateCubit`

**Files:**
- Create: `lib/features/sarpras/presentation/cubit/sarpras_teacher_candidate_cubit.dart`
- Create: `lib/features/sarpras/presentation/cubit/sarpras_teacher_candidate_state.dart`
- Modify: `lib/features/sarpras/sarpras_di.dart`
- Test: `test/features/sarpras/presentation/sarpras_teacher_candidate_cubit_test.dart` (create)

**Interfaces:**
- Consumes: `FetchSarprasTeacherCandidateUseCase()` returning `Future<Result<List<SarprasTeacherCandidate>>>`.
- Produces:
  - `SarprasTeacherCandidateCubit(FetchSarprasTeacherCandidateUseCase)` with
    `Future<void> fetchCandidates()`
  - `SarprasTeacherCandidateState` — `initial()`, `loading()`,
    `success({required List<SarprasTeacherCandidate> candidates})`,
    `empty()`, `failure(Failure failure)`

- [ ] **Step 1: Write the failing test**

Create `test/features/sarpras/presentation/sarpras_teacher_candidate_cubit_test.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras_teacher_candidate/sarpras_teacher_candidate.dart';
import 'package:my_bl/features/sarpras/domain/repositories/sarpras_repository.dart';
import 'package:my_bl/features/sarpras/domain/usecases/fetch_sarpras_teacher_candidate_use_case.dart';
import 'package:my_bl/features/sarpras/presentation/cubit/sarpras_teacher_candidate_cubit.dart';

class _MockSarprasRepository extends Mock implements SarprasRepository {}

const SarprasTeacherCandidate _teacher = SarprasTeacherCandidate(
  nip: '20250602',
  name: 'Budi Santoso',
);

void main() {
  test('emits success when candidates exist', () async {
    final repository = _MockSarprasRepository();
    when(
      () => repository.fetchSarprasTeacherCandidate(),
    ).thenAnswer((_) async => right([_teacher]));

    final cubit = SarprasTeacherCandidateCubit(
      FetchSarprasTeacherCandidateUseCase(repository),
    );
    addTearDown(cubit.close);

    final states = <SarprasTeacherCandidateState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.fetchCandidates();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(states, [
      const SarprasTeacherCandidateState.loading(),
      const SarprasTeacherCandidateState.success(candidates: [_teacher]),
    ]);
  });

  test('emits empty when the candidate list is empty', () async {
    final repository = _MockSarprasRepository();
    when(
      () => repository.fetchSarprasTeacherCandidate(),
    ).thenAnswer((_) async => right(<SarprasTeacherCandidate>[]));

    final cubit = SarprasTeacherCandidateCubit(
      FetchSarprasTeacherCandidateUseCase(repository),
    );
    addTearDown(cubit.close);

    final states = <SarprasTeacherCandidateState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.fetchCandidates();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(states, [
      const SarprasTeacherCandidateState.loading(),
      const SarprasTeacherCandidateState.empty(),
    ]);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sarpras/presentation/sarpras_teacher_candidate_cubit_test.dart`
Expected: FAIL — target of URI doesn't exist.

- [ ] **Step 3: Write the state**

Create `lib/features/sarpras/presentation/cubit/sarpras_teacher_candidate_state.dart`:

```dart
part of 'sarpras_teacher_candidate_cubit.dart';

@freezed
sealed class SarprasTeacherCandidateState
    with _$SarprasTeacherCandidateState {
  const factory SarprasTeacherCandidateState.initial() = _Initial;
  const factory SarprasTeacherCandidateState.loading() = _Loading;
  const factory SarprasTeacherCandidateState.success({
    required List<SarprasTeacherCandidate> candidates,
  }) = _Success;
  const factory SarprasTeacherCandidateState.empty() = _Empty;
  const factory SarprasTeacherCandidateState.failure(Failure failure) =
      _Failure;
}
```

- [ ] **Step 4: Write the cubit**

Create `lib/features/sarpras/presentation/cubit/sarpras_teacher_candidate_cubit.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/sarpras_teacher_candidate/sarpras_teacher_candidate.dart';
import '../../domain/usecases/fetch_sarpras_teacher_candidate_use_case.dart';

part 'sarpras_teacher_candidate_state.dart';
part 'sarpras_teacher_candidate_cubit.freezed.dart';

class SarprasTeacherCandidateCubit
    extends Cubit<SarprasTeacherCandidateState> {
  SarprasTeacherCandidateCubit(this._fetchSarprasTeacherCandidateUseCase)
    : super(const .initial());

  final FetchSarprasTeacherCandidateUseCase
  _fetchSarprasTeacherCandidateUseCase;

  Future<void> fetchCandidates() async {
    emit(const .loading());

    final result = await _fetchSarprasTeacherCandidateUseCase();

    return result.match((f) => emit(.failure(f)), (r) {
      if (r.isEmpty) return emit(const .empty());

      emit(.success(candidates: r));
    });
  }
}
```

- [ ] **Step 5: Register in DI**

In `lib/features/sarpras/sarpras_di.dart`:

```dart
import 'presentation/cubit/sarpras_teacher_candidate_cubit.dart';
```

```dart
  di.registerFactory<SarprasTeacherCandidateCubit>(
    () => SarprasTeacherCandidateCubit(
      di<FetchSarprasTeacherCandidateUseCase>(),
    ),
  );
```

- [ ] **Step 6: Regenerate and run the test**

Run: `dart run build_runner build --delete-conflicting-outputs`
Then: `flutter test test/features/sarpras/presentation/sarpras_teacher_candidate_cubit_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 7: Commit**

```bash
dart format . && flutter analyze
git add lib/features/sarpras test/features/sarpras
git commit -m "feat(sarpras): add SarprasTeacherCandidateCubit"
```

---

### Task 4: Localization keys

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_id.arb`

**Interfaces:**
- Produces: every `l10n.*` getter used by Tasks 5–11. Exact names below.

- [ ] **Step 1: Add the English strings**

Append to `lib/l10n/app_en.arb`, before the closing brace. Keep the existing
file's `@key` description style if neighbouring entries use it; plain keys
are acceptable where neighbours are plain.

```json
  "izinSarpras": "Facility Permit",
  "sarprasHistory": "Request History",
  "sarprasSubmitAction": "New Request",
  "sarprasFilterAll": "All",
  "sarprasStatusWaiting": "Pending",
  "sarprasStatusAccepted": "Approved",
  "sarprasStatusRejected": "Rejected",
  "sarprasEmptyTitle": "No requests yet",
  "sarprasEmptyMessage": "Submit a request to book a school facility.",
  "sarprasFilterEmptyTitle": "Nothing here",
  "sarprasFilterEmptyMessage": "No requests match this filter.",
  "sarprasLoadFailedTitle": "Could not load requests",
  "sarprasLoadFailedMessage": "Check your connection and try again.",
  "sarprasRetry": "Try again",
  "sarprasDetailTitle": "Request Detail",
  "sarprasFieldDate": "Activity date",
  "sarprasFieldName": "Activity name",
  "sarprasFieldStudentCount": "Number of students",
  "sarprasFieldTeacher": "Supervising teacher",
  "sarprasFieldStartTime": "Start time",
  "sarprasFieldEndTime": "End time",
  "sarprasFieldNote": "Notes",
  "sarprasResolvedBy": "Processed by",
  "sarprasResolvedAt": "Processed at",
  "sarprasRejectionReason": "Reason for rejection",
  "sarprasEditAction": "Edit",
  "sarprasCancelAction": "Withdraw",
  "sarprasCancelConfirmTitle": "Withdraw this request?",
  "sarprasCancelConfirmMessage": "This cannot be undone.",
  "sarprasCancelSuccess": "Request withdrawn.",
  "sarprasCreateTitle": "New Request",
  "sarprasEditTitle": "Edit Request",
  "sarprasSaveAction": "Submit",
  "sarprasCreateSuccess": "Request submitted, awaiting approval.",
  "sarprasUpdateSuccess": "Request updated.",
  "sarprasProcessedTitle": "Already processed",
  "sarprasProcessedMessage": "This request can no longer be changed.",
  "sarprasTeacherLoadFailed": "Could not load the teacher list.",
  "sarprasTeacherEmpty": "No supervising teachers available.",
  "sarprasValidationRequired": "This field is required.",
  "sarprasValidationPastDate": "Pick today or a later date.",
  "sarprasValidationEndBeforeStart": "End time must be after start time."
```

- [ ] **Step 2: Add the Indonesian strings**

Append the same keys to `lib/l10n/app_id.arb`:

```json
  "izinSarpras": "Izin Sarpras",
  "sarprasHistory": "Riwayat Pengajuan",
  "sarprasSubmitAction": "Ajukan",
  "sarprasFilterAll": "Semua",
  "sarprasStatusWaiting": "Menunggu",
  "sarprasStatusAccepted": "Disetujui",
  "sarprasStatusRejected": "Ditolak",
  "sarprasEmptyTitle": "Belum ada pengajuan",
  "sarprasEmptyMessage": "Ajukan izin untuk memakai sarana sekolah.",
  "sarprasFilterEmptyTitle": "Kosong",
  "sarprasFilterEmptyMessage": "Tidak ada pengajuan pada filter ini.",
  "sarprasLoadFailedTitle": "Gagal memuat pengajuan",
  "sarprasLoadFailedMessage": "Periksa koneksi lalu coba lagi.",
  "sarprasRetry": "Coba lagi",
  "sarprasDetailTitle": "Detail Pengajuan",
  "sarprasFieldDate": "Tanggal kegiatan",
  "sarprasFieldName": "Nama kegiatan",
  "sarprasFieldStudentCount": "Jumlah siswa",
  "sarprasFieldTeacher": "Guru pembimbing",
  "sarprasFieldStartTime": "Jam mulai",
  "sarprasFieldEndTime": "Jam selesai",
  "sarprasFieldNote": "Keterangan",
  "sarprasResolvedBy": "Diproses oleh",
  "sarprasResolvedAt": "Diproses pada",
  "sarprasRejectionReason": "Alasan penolakan",
  "sarprasEditAction": "Ubah",
  "sarprasCancelAction": "Batalkan",
  "sarprasCancelConfirmTitle": "Batalkan pengajuan ini?",
  "sarprasCancelConfirmMessage": "Tindakan ini tidak bisa dibatalkan.",
  "sarprasCancelSuccess": "Pengajuan dibatalkan.",
  "sarprasCreateTitle": "Ajukan Izin",
  "sarprasEditTitle": "Ubah Pengajuan",
  "sarprasSaveAction": "Kirim",
  "sarprasCreateSuccess": "Pengajuan terkirim, menunggu persetujuan.",
  "sarprasUpdateSuccess": "Pengajuan diperbarui.",
  "sarprasProcessedTitle": "Sudah diproses",
  "sarprasProcessedMessage": "Pengajuan ini tidak bisa diubah lagi.",
  "sarprasTeacherLoadFailed": "Gagal memuat daftar guru.",
  "sarprasTeacherEmpty": "Tidak ada guru pembimbing tersedia.",
  "sarprasValidationRequired": "Wajib diisi.",
  "sarprasValidationPastDate": "Pilih hari ini atau setelahnya.",
  "sarprasValidationEndBeforeStart": "Jam selesai harus setelah jam mulai."
```

- [ ] **Step 3: Regenerate localizations and verify**

The project has `l10n.yaml` with `arb-dir: lib/l10n` and `generate: true` in
`pubspec.yaml`, so generation runs on build.

Run: `flutter gen-l10n`
Then: `flutter analyze lib/l10n`
Expected: no issues; `AppLocalizations` exposes the new getters.

- [ ] **Step 4: Commit**

```bash
dart format . && flutter analyze
git add lib/l10n
git commit -m "feat(sarpras): add localization strings"
```

---

### Task 5: Status badge and list item widgets

**Files:**
- Create: `lib/features/sarpras/presentation/widgets/sarpras_status_badge.dart`
- Create: `lib/features/sarpras/presentation/widgets/sarpras_list_item.dart`
- Test: `test/features/sarpras/presentation/widgets/sarpras_list_item_test.dart` (create)

**Interfaces:**
- Consumes: `Sarpras` entity, l10n keys from Task 4.
- Produces:
  - `SarprasStatusBadge({required String status})`
  - `SarprasListItem({required Sarpras sarpras, required VoidCallback onTap})`

- [ ] **Step 1: Write the failing test**

Create `test/features/sarpras/presentation/widgets/sarpras_list_item_test.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras/sarpras.dart';
import 'package:my_bl/features/sarpras/presentation/widgets/sarpras_list_item.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/l10n/app_localizations_en.dart';

final AppLocalizationsEn _l10n = AppLocalizationsEn();

Sarpras _sarpras({String status = 'Menunggu'}) => Sarpras(
  id: 4,
  unit: 'SMAKT',
  nis: '24251026',
  tanggalKegiatan: DateTime(2026, 7, 23),
  namaKegiatan: 'Meeting IT',
  jumlahSiswaDalamKegiatan: '5',
  nipGuruPembimbing: '20250602',
  waktuKegiatan: '12.00 - 15.00',
  status: status,
);

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: const [Locale('en')],
  home: Scaffold(body: child),
);

void main() {
  testWidgets('shows activity name, time, and localized status', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(SarprasListItem(sarpras: _sarpras(), onTap: () {})),
    );

    expect(find.text('Meeting IT'), findsOneWidget);
    expect(find.textContaining('12.00 - 15.00'), findsOneWidget);
    expect(find.text(_l10n.sarprasStatusWaiting), findsOneWidget);
  });

  testWidgets('reports taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(SarprasListItem(sarpras: _sarpras(), onTap: () => tapped = true)),
    );
    await tester.tap(find.byType(SarprasListItem));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sarpras/presentation/widgets/sarpras_list_item_test.dart`
Expected: FAIL — target of URI doesn't exist.

- [ ] **Step 3: Write the status badge**

Create `lib/features/sarpras/presentation/widgets/sarpras_status_badge.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../l10n/app_localizations.dart';

/// A compact coloured label for a request status.
class SarprasStatusBadge extends StatelessWidget {
  const SarprasStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (String label, Color background, Color foreground) =
        switch (status) {
          'Disetujui' => (
            l10n.sarprasStatusAccepted,
            colors.success.withValues(alpha: 0.15),
            colors.success,
          ),
          'Ditolak' => (
            l10n.sarprasStatusRejected,
            scheme.errorContainer,
            scheme.onErrorContainer,
          ),
          _ => (
            l10n.sarprasStatusWaiting,
            colors.warning.withValues(alpha: 0.15),
            colors.warning,
          ),
        };

    return AppChipContainer(
      value: label,
      backgroundColor: background,
      foregroundColor: foreground,
    );
  }
}
```

`AppColors` is the `ThemeExtension` declared in
`lib/core/theme/app_theme.dart` (not a separate `app_colors.dart`). It
exposes `success`, `warning`, and `checkOut`, and `AppColors.of(context)`
falls back to defaults when the extension is absent — so this is safe in
widget tests that build a bare `MaterialApp`.

- [ ] **Step 4: Write the list item**

Create `lib/features/sarpras/presentation/widgets/sarpras_list_item.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../domain/entities/sarpras/sarpras.dart';
import 'sarpras_status_badge.dart';

/// A single request row in the sarpras list.
class SarprasListItem extends StatelessWidget {
  const SarprasListItem({
    super.key,
    required this.sarpras,
    required this.onTap,
  });

  final Sarpras sarpras;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sarpras.namaKegiatan,
                    style: textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.h,
                  Text(
                    '${sarpras.tanggalKegiatan.toDayMonthYearFormat(context)}'
                    ' • ${sarpras.waktuKegiatan}',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            8.w,
            SarprasStatusBadge(status: sarpras.status),
          ],
        ),
      ),
    );
  }
}
```

Note: no horizontal padding — `AppSliverGroup.contentPadding` already
supplies 16 on each side in Task 7.

- [ ] **Step 5: Run the test**

Run: `flutter test test/features/sarpras/presentation/widgets/sarpras_list_item_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 6: Commit**

```bash
dart format . && flutter analyze
git add lib/features/sarpras test/features/sarpras
git commit -m "feat(sarpras): add status badge and list item widgets"
```

---

### Task 6: Summary filter chips

**Files:**
- Create: `lib/features/sarpras/presentation/widgets/sarpras_summary_chips.dart`
- Test: `test/features/sarpras/presentation/widgets/sarpras_summary_chips_test.dart` (create)

**Interfaces:**
- Consumes: `SarprasSummary` entity, l10n keys from Task 4.
- Produces:
  - `enum SarprasFilter { all, waiting, accepted, rejected }`
  - `SarprasSummaryChips({required SarprasSummary summary, required SarprasFilter selected, required ValueChanged<SarprasFilter> onSelected})`
  - `extension SarprasFilterMatcher on SarprasFilter { bool matches(String status) }`

- [ ] **Step 1: Write the failing test**

Create `test/features/sarpras/presentation/widgets/sarpras_summary_chips_test.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras_summary/sarpras_summary.dart';
import 'package:my_bl/features/sarpras/presentation/widgets/sarpras_summary_chips.dart';
import 'package:my_bl/l10n/app_localizations.dart';

const SarprasSummary _summary = SarprasSummary(
  waiting: 3,
  accepted: 2,
  rejected: 0,
);

void main() {
  test('filter matches the right status strings', () {
    expect(SarprasFilter.all.matches('Ditolak'), isTrue);
    expect(SarprasFilter.waiting.matches('Menunggu'), isTrue);
    expect(SarprasFilter.waiting.matches('Disetujui'), isFalse);
    expect(SarprasFilter.accepted.matches('Disetujui'), isTrue);
    expect(SarprasFilter.rejected.matches('Ditolak'), isTrue);
  });

  testWidgets('renders a chip per status with its count', (tester) async {
    SarprasFilter? picked;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: SarprasSummaryChips(
            summary: _summary,
            selected: SarprasFilter.all,
            onSelected: (value) => picked = value,
          ),
        ),
      ),
    );

    expect(find.textContaining('5'), findsWidgets);
    expect(find.textContaining('3'), findsWidgets);

    await tester.tap(find.textContaining('3').first);
    await tester.pumpAndSettle();

    expect(picked, SarprasFilter.waiting);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sarpras/presentation/widgets/sarpras_summary_chips_test.dart`
Expected: FAIL — target of URI doesn't exist.

- [ ] **Step 3: Write the widget**

Create `lib/features/sarpras/presentation/widgets/sarpras_summary_chips.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/sarpras_summary/sarpras_summary.dart';

/// Which subset of requests the list is showing.
enum SarprasFilter { all, waiting, accepted, rejected }

extension SarprasFilterMatcher on SarprasFilter {
  /// Whether a request with [status] belongs in this filter.
  bool matches(String status) => switch (this) {
    SarprasFilter.all => true,
    SarprasFilter.waiting => status == 'Menunggu',
    SarprasFilter.accepted => status == 'Disetujui',
    SarprasFilter.rejected => status == 'Ditolak',
  };
}

/// A row of selectable status chips showing per-status counts.
class SarprasSummaryChips extends StatelessWidget {
  const SarprasSummaryChips({
    super.key,
    required this.summary,
    required this.selected,
    required this.onSelected,
  });

  final SarprasSummary summary;
  final SarprasFilter selected;
  final ValueChanged<SarprasFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = summary.waiting + summary.accepted + summary.rejected;

    final entries = <(SarprasFilter, String, int)>[
      (SarprasFilter.all, l10n.sarprasFilterAll, total),
      (SarprasFilter.waiting, l10n.sarprasStatusWaiting, summary.waiting),
      (SarprasFilter.accepted, l10n.sarprasStatusAccepted, summary.accepted),
      (SarprasFilter.rejected, l10n.sarprasStatusRejected, summary.rejected),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: entries
            .map(
              (entry) => FilterChip(
                label: Text('${entry.$2} (${entry.$3})'),
                selected: selected == entry.$1,
                onSelected: entry.$3 == 0 && entry.$1 != SarprasFilter.all
                    ? null
                    : (_) => onSelected(entry.$1),
              ),
            )
            .toList()
            .separatedBy(8.w),
      ),
    );
  }
}
```

`FilterChip` with a null `onSelected` renders disabled, which is how
zero-count chips stay visible without shifting layout.

- [ ] **Step 4: Run the test**

Run: `flutter test test/features/sarpras/presentation/widgets/sarpras_summary_chips_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 5: Commit**

```bash
dart format . && flutter analyze
git add lib/features/sarpras test/features/sarpras
git commit -m "feat(sarpras): add summary filter chips"
```

---

### Task 7: List screen

**Files:**
- Create: `lib/features/sarpras/presentation/screens/sarpras_screen.dart`
- Test: `test/features/sarpras/presentation/screens/sarpras_screen_test.dart` (create)

**Interfaces:**
- Consumes: `SarprasBloc`, `SarprasSummaryChips`, `SarprasFilter`,
  `SarprasListItem`, l10n from Task 4.
- Produces: `SarprasScreen()` — a `StatelessWidget` providing `SarprasBloc`.

Read `lib/features/discipline/presentation/screens/merit_demerit_screen.dart`
first and mirror its Screen → View → AppBar → Body structure.

- [ ] **Step 1: Write the failing tests**

Create `test/features/sarpras/presentation/screens/sarpras_screen_test.dart`.
Provide the bloc with `BlocProvider.value` over a mocked `SarprasBloc` so the
screen's own `di<SarprasBloc>()` is bypassed; test the private view through
the public `SarprasScreen` only if DI is registered, otherwise export a
testable body. The simplest approach that avoids DI in tests: make the
screen's body widget public as `SarprasBody` and test that directly.

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/core/failure/failure.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras/sarpras.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras_summary/sarpras_summary.dart';
import 'package:my_bl/features/sarpras/presentation/bloc/sarpras_bloc.dart';
import 'package:my_bl/features/sarpras/presentation/screens/sarpras_screen.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/l10n/app_localizations_en.dart';

class _MockSarprasBloc extends Mock implements SarprasBloc {}

final AppLocalizationsEn _l10n = AppLocalizationsEn();

const SarprasSummary _summary = SarprasSummary(
  waiting: 1,
  accepted: 1,
  rejected: 0,
);

Sarpras _sarpras({required int id, required String status}) => Sarpras(
  id: id,
  unit: 'SMAKT',
  nis: '24251026',
  tanggalKegiatan: DateTime(2026, 7, 23),
  namaKegiatan: 'Kegiatan $id',
  jumlahSiswaDalamKegiatan: '5',
  nipGuruPembimbing: '20250602',
  waktuKegiatan: '12.00 - 15.00',
  status: status,
);

SarprasBloc _bloc(SarprasState state) {
  final bloc = _MockSarprasBloc();
  when(() => bloc.state).thenReturn(state);
  when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
  return bloc;
}

Widget _wrap(SarprasBloc bloc) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: const [Locale('en')],
  home: BlocProvider<SarprasBloc>.value(value: bloc, child: SarprasBody()),
);

void main() {
  testWidgets('shows the empty state when nothing was submitted', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(_bloc(const SarprasState.empty(summary: _summary))),
    );
    await tester.pumpAndSettle();

    expect(find.text(_l10n.sarprasEmptyTitle), findsOneWidget);
  });

  testWidgets('shows the failure state with a retry action', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _bloc(const SarprasState.failure(Failure.unexpected())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_l10n.sarprasLoadFailedTitle), findsOneWidget);
    expect(find.text(_l10n.sarprasRetry), findsOneWidget);
  });

  testWidgets('lists every request when no filter is applied', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _bloc(
          SarprasState.success(
            summary: _summary,
            listSarpras: [
              _sarpras(id: 1, status: 'Menunggu'),
              _sarpras(id: 2, status: 'Disetujui'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kegiatan 1'), findsOneWidget);
    expect(find.text('Kegiatan 2'), findsOneWidget);
  });

  testWidgets('narrows the list when a status chip is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        _bloc(
          SarprasState.success(
            summary: _summary,
            listSarpras: [
              _sarpras(id: 1, status: 'Menunggu'),
              _sarpras(id: 2, status: 'Disetujui'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(_l10n.sarprasStatusAccepted).first);
    await tester.pumpAndSettle();

    expect(find.text('Kegiatan 1'), findsNothing);
    expect(find.text('Kegiatan 2'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/sarpras/presentation/screens/sarpras_screen_test.dart`
Expected: FAIL — target of URI doesn't exist.

- [ ] **Step 3: Write the screen**

Create `lib/features/sarpras/presentation/screens/sarpras_screen.dart`.
`SarprasBody` is public so widget tests can mount it without DI.

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/route_names.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/sarpras_bloc.dart';
import '../widgets/sarpras_list_item.dart';
import '../widgets/sarpras_summary_chips.dart';

/// Entry screen listing the student's facility-use requests.
class SarprasScreen extends StatelessWidget {
  const SarprasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SarprasBloc>(
      create: (_) => di<SarprasBloc>(),
      child: const _SarprasView(),
    );
  }
}

class _SarprasView extends StatefulWidget {
  const _SarprasView();

  @override
  State<_SarprasView> createState() => _SarprasViewState();
}

class _SarprasViewState extends State<_SarprasView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SarprasBloc>().add(const SarprasEvent.fetchSarpras());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppTopBar(toolbarHeight: 72, title: Text(l10n.izinSarpras)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.sarprasNew),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.sarprasSubmitAction),
      ),
      body: const SarprasBody(),
    );
  }
}

/// The scrollable body of the sarpras screen.
///
/// Public so widget tests can mount it with a provided [SarprasBloc]
/// instead of resolving one through the service locator.
class SarprasBody extends StatefulWidget {
  const SarprasBody({super.key});

  @override
  State<SarprasBody> createState() => _SarprasBodyState();
}

class _SarprasBodyState extends State<SarprasBody> {
  SarprasFilter _filter = SarprasFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshWrapper(
      onRefresh: () => blocRefresh<SarprasBloc, SarprasEvent, SarprasState>(
        context: context,
        event: const SarprasEvent.fetchSarpras(),
        isDone: (state) => state.maybeWhen(
          success: (_, _) => true,
          empty: (_) => true,
          failure: (_) => true,
          orElse: () => false,
        ),
      ),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          BlocBuilder<SarprasBloc, SarprasState>(
            builder: (context, state) => state.maybeWhen(
              failure: (_) => SliverToBoxAdapter(child: 0.h),
              orElse: () => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SarprasSummaryChips(
                    summary: state.maybeWhen(
                      success: (summary, _) => summary,
                      empty: (summary) => summary,
                      orElse: () => const SarprasSummary(
                        waiting: 0,
                        accepted: 0,
                        rejected: 0,
                      ),
                    ),
                    selected: _filter,
                    onSelected: (value) => setState(() => _filter = value),
                  ),
                ),
              ),
            ),
            buildWhen: (previous, current) => previous != current,
          ),
          BlocBuilder<SarprasBloc, SarprasState>(
            builder: (context, state) => state.maybeWhen(
              failure: (_) => AppEmptyStateSliver(
                icon: Icons.error_outline_rounded,
                title: l10n.sarprasLoadFailedTitle,
                message: l10n.sarprasLoadFailedMessage,
                retryLabel: l10n.sarprasRetry,
                onRetry: () => context.read<SarprasBloc>().add(
                  const SarprasEvent.fetchSarpras(),
                ),
              ),
              empty: (_) => AppSliverGroup(
                title: l10n.sarprasHistory,
                sliver: AppEmptyStateSliver(
                  icon: Icons.inbox_rounded,
                  title: l10n.sarprasEmptyTitle,
                  message: l10n.sarprasEmptyMessage,
                ),
              ),
              success: (_, listSarpras) {
                final visible = listSarpras
                    .where((item) => _filter.matches(item.status))
                    .toList();

                return AppSliverGroup(
                  title: l10n.sarprasHistory,
                  sliver: visible.isEmpty
                      ? AppEmptyStateSliver(
                          icon: Icons.filter_alt_off_rounded,
                          title: l10n.sarprasFilterEmptyTitle,
                          message: l10n.sarprasFilterEmptyMessage,
                        )
                      : SliverList.builder(
                          itemCount: visible.length,
                          itemBuilder: (context, index) => SarprasListItem(
                            sarpras: visible[index],
                            onTap: () => context.push(
                              '/sarpras/${visible[index].id}',
                            ),
                          ),
                        ),
                );
              },
              orElse: () => AppSliverGroup(
                title: l10n.sarprasHistory,
                sliver: SliverList.builder(
                  itemCount: 4,
                  itemBuilder: (context, _) =>
                      const _SarprasListItemSkeleton(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: 96.h),
        ],
      ),
    );
  }
}

class _SarprasListItemSkeleton extends StatelessWidget {
  const _SarprasListItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
      ).toShimmer(context, isLoading: true),
    );
  }
}
```

`SarprasState.success` takes `summary` and `listSarpras`, and
`SarprasState.empty` takes `summary` — so the `maybeWhen` lambdas are
`success: (summary, listSarpras)` and `empty: (summary)`, as written above.

- [ ] **Step 4: Run the tests**

Run: `flutter test test/features/sarpras/presentation/screens/sarpras_screen_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
dart format . && flutter analyze
git add lib/features/sarpras test/features/sarpras
git commit -m "feat(sarpras): add list screen with status filtering"
```

---

### Task 8: Cupertino sheet page and routes

**Files:**
- Create: `lib/core/app_router/cupertino_sheet_page.dart`
- Modify: `lib/core/app_router/route_names.dart`
- Modify: `lib/core/app_router/app_router.dart`

**Interfaces:**
- Produces:
  - `CupertinoSheetPage<T>({required Widget child, LocalKey? key, String? name})`
  - `RouteNames.sarpras` = `/sarpras`
  - `RouteNames.sarprasNew` = `/sarpras/new`
  - `RouteNames.sarprasDetail` = `/sarpras/:id`
  - `RouteNames.sarprasEdit` = `/sarpras/:id/edit`

Detail and form screens land in Tasks 9 and 10. Wire only `/sarpras` here
and add the three sheet routes in Task 10, when their screens exist.

- [ ] **Step 1: Write the sheet page**

Create `lib/core/app_router/cupertino_sheet_page.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';

/// A go_router [Page] that presents its child as an iOS-style sheet.
///
/// Keeps sheet destinations inside the router so they stay deep-linkable
/// instead of being pushed imperatively onto the [Navigator].
class CupertinoSheetPage<T> extends Page<T> {
  const CupertinoSheetPage({
    required this.child,
    this.enableDrag = true,
    super.key,
    super.name,
  });

  /// The sheet's content.
  final Widget child;

  /// Whether the sheet can be dismissed by dragging it down.
  final bool enableDrag;

  @override
  Route<T> createRoute(BuildContext context) => CupertinoSheetRoute<T>(
    builder: (_) => child,
    enableDrag: enableDrag,
    settings: this,
  );
}
```

- [ ] **Step 2: Add the route names**

In `lib/core/app_router/route_names.dart`, following the existing spacing and
doc-comment style of its neighbours:

```dart
  static const String sarpras = "/sarpras";

  static const String sarprasNew = "/sarpras/new";

  static const String sarprasDetail = "/sarpras/:id";

  static const String sarprasEdit = "/sarpras/:id/edit";
```

- [ ] **Step 3: Add the list route**

In `lib/core/app_router/app_router.dart`, add the import beside the other
screen imports and a `GoRoute` beside `RouteNames.extracurricular`:

```dart
import '../../features/sarpras/presentation/screens/sarpras_screen.dart';
```

```dart
      GoRoute(
        path: RouteNames.sarpras,
        builder: (context, state) => const SarprasScreen(),
      ),
```

- [ ] **Step 4: Verify the app still builds**

Run: `flutter analyze`
Expected: no issues.

- [ ] **Step 5: Commit**

```bash
dart format . && flutter analyze
git add lib/core/app_router
git commit -m "feat(sarpras): add sheet page and list route"
```

---

### Task 9: Detail sheet

**Files:**
- Create: `lib/features/sarpras/presentation/screens/sarpras_detail_sheet.dart`
- Test: `test/features/sarpras/presentation/screens/sarpras_detail_sheet_test.dart` (create)

**Interfaces:**
- Consumes: `DetailSarprasCubit` (Task 2), `DestroySarprasCubit`,
  `Sarpras.isCancelable` (Task 1), l10n (Task 4).
- Produces: `SarprasDetailSheet({required int sarprasId})` and a public
  `SarprasDetailBody({required int sarprasId})` for testing without DI.

- [ ] **Step 1: Write the failing tests**

Create `test/features/sarpras/presentation/screens/sarpras_detail_sheet_test.dart`:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras/sarpras.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras_metadata/sarpras_metadata.dart';
import 'package:my_bl/features/sarpras/presentation/cubit/destroy_sarpras_cubit.dart';
import 'package:my_bl/features/sarpras/presentation/cubit/detail_sarpras_cubit.dart';
import 'package:my_bl/features/sarpras/presentation/screens/sarpras_detail_sheet.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/l10n/app_localizations_en.dart';

class _MockDetailCubit extends Mock implements DetailSarprasCubit {}

class _MockDestroyCubit extends Mock implements DestroySarprasCubit {}

final AppLocalizationsEn _l10n = AppLocalizationsEn();

Sarpras _sarpras({required String status, String? alasanTolak}) => Sarpras(
  id: 4,
  unit: 'SMAKT',
  nis: '24251026',
  tanggalKegiatan: DateTime(2026, 7, 23),
  namaKegiatan: 'Meeting IT',
  jumlahSiswaDalamKegiatan: '5',
  nipGuruPembimbing: '20250602',
  waktuKegiatan: '12.00 - 15.00',
  status: status,
  metadata: SarprasMetadata(alasanTolak: alasanTolak),
);

Widget _wrap(Sarpras sarpras) {
  final detail = _MockDetailCubit();
  when(() => detail.state).thenReturn(
    DetailSarprasState.success(sarpras: sarpras),
  );
  when(() => detail.stream).thenAnswer((_) => const Stream.empty());

  final destroy = _MockDestroyCubit();
  when(() => destroy.state).thenReturn(const DestroySarprasState.initial());
  when(() => destroy.stream).thenAnswer((_) => const Stream.empty());

  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: MultiBlocProvider(
      providers: [
        BlocProvider<DetailSarprasCubit>.value(value: detail),
        BlocProvider<DestroySarprasCubit>.value(value: destroy),
      ],
      child: const SarprasDetailBody(sarprasId: 4),
    ),
  );
}

void main() {
  testWidgets('offers edit and withdraw while pending', (tester) async {
    await tester.pumpWidget(_wrap(_sarpras(status: 'Menunggu')));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.sarprasEditAction), findsOneWidget);
    expect(find.text(_l10n.sarprasCancelAction), findsOneWidget);
  });

  testWidgets('hides both actions once approved', (tester) async {
    await tester.pumpWidget(_wrap(_sarpras(status: 'Disetujui')));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.sarprasEditAction), findsNothing);
    expect(find.text(_l10n.sarprasCancelAction), findsNothing);
  });

  testWidgets('hides both actions once rejected and shows the reason', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(_sarpras(status: 'Ditolak', alasanTolak: 'Ruangan dipakai')),
    );
    await tester.pumpAndSettle();

    expect(find.text(_l10n.sarprasEditAction), findsNothing);
    expect(find.text(_l10n.sarprasCancelAction), findsNothing);
    expect(find.text('Ruangan dipakai'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/sarpras/presentation/screens/sarpras_detail_sheet_test.dart`
Expected: FAIL — target of URI doesn't exist.

- [ ] **Step 3: Write the sheet**

Create `lib/features/sarpras/presentation/screens/sarpras_detail_sheet.dart`.

Structure:
- `SarprasDetailSheet` — `StatelessWidget`, wraps `SarprasDetailBody` in a
  `MultiBlocProvider` creating `di<DetailSarprasCubit>()` and
  `di<DestroySarprasCubit>()`.
- `SarprasDetailBody` — `StatefulWidget`; in `initState`, post-frame, calls
  `context.read<DetailSarprasCubit>().fetchDetail(sarprasId: widget.sarprasId)`.
- Body is a `Scaffold` with an `AppTopBar` titled `l10n.sarprasDetailTitle`
  and a close `IconButton` (`Icons.close_rounded`) that calls `context.pop()`.
- `BlocBuilder<DetailSarprasCubit, DetailSarprasState>` renders:
  - `loading`/`initial` → a centred `CircularProgressIndicator.adaptive()`
  - `failure` → `AppEmptyState` with `retryLabel: l10n.sarprasRetry` and
    `onRetry` re-calling `fetchDetail`
  - `success` → the field rows, then the resolution block, then the actions
- Field rows: label from l10n, value from the entity. Date uses
  `sarpras.tanggalKegiatan.toDayDateMonthYearFormat(context)`. Extract a
  private `_DetailRow({required String label, required String value})` and
  reuse it; do not repeat the `Row` markup per field.
- Resolution block renders only when `sarpras.metadata != null` and at least
  one of `nameResolver`, `resolvedAt`, `alasanTolak` is non-null. When
  `alasanTolak` is non-null it renders first, in a container tinted with
  `Theme.of(context).colorScheme.errorContainer`, labelled
  `l10n.sarprasRejectionReason`.
- Actions render only when `sarpras.isCancelable`:
  ```dart
  Row(
    children: [
      Expanded(
        child: AppButton.outlined(
          onPressed: () => context.push('/sarpras/${sarpras.id}/edit'),
          child: Text(l10n.sarprasEditAction),
        ),
      ),
      12.w,
      Expanded(
        child: AppButton.text(
          onPressed: () => _confirmCancel(context, sarpras.id),
          child: Text(l10n.sarprasCancelAction),
        ),
      ),
    ],
  )
  ```
- `_confirmCancel` shows an `AlertDialog` titled
  `l10n.sarprasCancelConfirmTitle` with content
  `l10n.sarprasCancelConfirmMessage`, a `l10n.cancel` dismiss action, and a
  `l10n.confirm` action that pops the dialog then calls
  `context.read<DestroySarprasCubit>().destroySarpras(sarprasId: id)`.
- A `BlocListener<DestroySarprasCubit, DestroySarprasState>` wraps the body:
  on `success`, show `AppToast.success(context, l10n.sarprasCancelSuccess)`
  then `context.pop(true)`; on `failure`, show
  `AppToast.error(context, failure.messageKey)` and stay open.

`AppButton.outlined` and `AppButton.text` both exist as const named
constructors taking `child` and `onPressed`, mirroring the default
`AppButton`.

- [ ] **Step 4: Run the tests**

Run: `flutter test test/features/sarpras/presentation/screens/sarpras_detail_sheet_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
dart format . && flutter analyze
git add lib/features/sarpras test/features/sarpras
git commit -m "feat(sarpras): add detail sheet with guarded actions"
```

---

### Task 10: Form sheet and sheet routes

**Files:**
- Create: `lib/features/sarpras/presentation/screens/sarpras_form_sheet.dart`
- Modify: `lib/core/app_router/app_router.dart`
- Test: `test/features/sarpras/presentation/screens/sarpras_form_sheet_test.dart` (create)

**Interfaces:**
- Consumes: `StoreSarprasCubit`, `UpdateSarprasCubit`, `DetailSarprasCubit`,
  `SarprasTeacherCandidateCubit`, `SarprasParams`, l10n (Task 4),
  `CupertinoSheetPage` and `RouteNames.sarpras*` (Task 8).
- Produces: `SarprasFormSheet({int? sarprasId})` — null id means create.
  Public `SarprasFormBody({int? sarprasId})` for testing without DI.

- [ ] **Step 1: Write the failing tests**

Create `test/features/sarpras/presentation/screens/sarpras_form_sheet_test.dart`
covering three behaviours. Mock `SarprasTeacherCandidateCubit`,
`StoreSarprasCubit`, and `DetailSarprasCubit`; mount `SarprasFormBody`.

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras/sarpras.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras_teacher_candidate/sarpras_teacher_candidate.dart';
import 'package:my_bl/features/sarpras/presentation/cubit/detail_sarpras_cubit.dart';
import 'package:my_bl/features/sarpras/presentation/cubit/sarpras_teacher_candidate_cubit.dart';
import 'package:my_bl/features/sarpras/presentation/cubit/store_sarpras_cubit.dart';
import 'package:my_bl/features/sarpras/presentation/cubit/update_sarpras_cubit.dart';
import 'package:my_bl/features/sarpras/presentation/screens/sarpras_form_sheet.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/l10n/app_localizations_en.dart';

class _MockCandidateCubit extends Mock
    implements SarprasTeacherCandidateCubit {}

class _MockStoreCubit extends Mock implements StoreSarprasCubit {}

class _MockUpdateCubit extends Mock implements UpdateSarprasCubit {}

class _MockDetailCubit extends Mock implements DetailSarprasCubit {}

final AppLocalizationsEn _l10n = AppLocalizationsEn();

const SarprasTeacherCandidate _teacher = SarprasTeacherCandidate(
  nip: '20250602',
  name: 'Budi Santoso',
);

final Sarpras _processed = Sarpras(
  id: 4,
  unit: 'SMAKT',
  nis: '24251026',
  tanggalKegiatan: DateTime(2026, 7, 23),
  namaKegiatan: 'Meeting IT',
  jumlahSiswaDalamKegiatan: '5',
  nipGuruPembimbing: '20250602',
  waktuKegiatan: '12.00 - 15.00',
  status: 'Disetujui',
);

Widget _wrap({
  required SarprasTeacherCandidateState candidateState,
  DetailSarprasState? detailState,
  int? sarprasId,
}) {
  final candidates = _MockCandidateCubit();
  when(() => candidates.state).thenReturn(candidateState);
  when(() => candidates.stream).thenAnswer((_) => const Stream.empty());

  final store = _MockStoreCubit();
  when(() => store.state).thenReturn(const StoreSarprasState.initial());
  when(() => store.stream).thenAnswer((_) => const Stream.empty());

  final update = _MockUpdateCubit();
  when(() => update.state).thenReturn(const UpdateSarprasState.initial());
  when(() => update.stream).thenAnswer((_) => const Stream.empty());

  final detail = _MockDetailCubit();
  when(
    () => detail.state,
  ).thenReturn(detailState ?? const DetailSarprasState.initial());
  when(() => detail.stream).thenAnswer((_) => const Stream.empty());

  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: MultiBlocProvider(
      providers: [
        BlocProvider<SarprasTeacherCandidateCubit>.value(value: candidates),
        BlocProvider<StoreSarprasCubit>.value(value: store),
        BlocProvider<UpdateSarprasCubit>.value(value: update),
        BlocProvider<DetailSarprasCubit>.value(value: detail),
      ],
      child: SarprasFormBody(sarprasId: sarprasId),
    ),
  );
}

void main() {
  testWidgets('warns and blocks submit when no teachers are available', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(candidateState: const SarprasTeacherCandidateState.empty()),
    );
    await tester.pumpAndSettle();

    expect(find.text(_l10n.sarprasTeacherEmpty), findsOneWidget);

    final button = tester.widget<AppButton>(find.byType(AppButton).last);
    expect(button.onPressed, isNull);
  });

  testWidgets('rejects an end time that is not after the start time', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        candidateState: const SarprasTeacherCandidateState.success(
          candidates: [_teacher],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Drive the form through its public API: set both times to 12:00 via
    // the widget's exposed test hook, then submit.
    final state = tester.state<SarprasFormBodyState>(
      find.byType(SarprasFormBody),
    );
    state.debugSetTimes(
      start: const TimeOfDay(hour: 12, minute: 0),
      end: const TimeOfDay(hour: 12, minute: 0),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(_l10n.sarprasSaveAction));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.sarprasValidationEndBeforeStart), findsOneWidget);
  });

  testWidgets('shows the processed state instead of a form when not editable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        candidateState: const SarprasTeacherCandidateState.success(
          candidates: [_teacher],
        ),
        detailState: DetailSarprasState.success(sarpras: _processed),
        sarprasId: 4,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_l10n.sarprasProcessedTitle), findsOneWidget);
    expect(find.text(_l10n.sarprasSaveAction), findsNothing);
  });
}
```

Add `import 'package:my_bl/core/widgets/app_button.dart';` to the test.

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/sarpras/presentation/screens/sarpras_form_sheet_test.dart`
Expected: FAIL — target of URI doesn't exist.

- [ ] **Step 3: Write the form sheet**

Create `lib/features/sarpras/presentation/screens/sarpras_form_sheet.dart`.

Structure:
- `SarprasFormSheet({int? sarprasId})` — `StatelessWidget` wrapping
  `SarprasFormBody` in a `MultiBlocProvider` creating
  `di<SarprasTeacherCandidateCubit>()`, `di<StoreSarprasCubit>()`,
  `di<UpdateSarprasCubit>()`, and `di<DetailSarprasCubit>()`.
- `SarprasFormBody({int? sarprasId})` — `StatefulWidget` whose state class is
  named `SarprasFormBodyState` (public, no leading underscore, so tests can
  reach `debugSetTimes`).
- `initState` post-frame: always call `fetchCandidates()`; when
  `sarprasId != null` also call `fetchDetail(sarprasId: sarprasId!)`.
- State fields: `_formKey` (`GlobalKey<FormState>`), `TextEditingController`
  for name, student count, and note; `DateTime? _date`;
  `TimeOfDay? _start`; `TimeOfDay? _end`; `String? _nip`;
  `String? _timeError`. Dispose all controllers.
- Add the test hook:
  ```dart
  @visibleForTesting
  void debugSetTimes({required TimeOfDay start, required TimeOfDay end}) {
    setState(() {
      _start = start;
      _end = end;
    });
  }
  ```
  Import `package:flutter/foundation.dart` for `@visibleForTesting`.
- When `sarprasId != null`, a
  `BlocListener<DetailSarprasCubit, DetailSarprasState>` populates the
  controllers once on `success`. If that `Sarpras` is not `isCancelable`,
  render `AppEmptyState(icon: Icons.lock_clock_rounded, title:
  l10n.sarprasProcessedTitle, message: l10n.sarprasProcessedMessage)` and no
  form.
- Fields, wrapped in a `Form`, inside a scrollable column with 16 horizontal
  padding:
  - Date: an `InkWell` showing the formatted `_date` (or
    `l10n.sarprasFieldDate`) that calls `showDatePicker` with
    `firstDate: DateUtils.dateOnly(DateTime.now())`. Rejecting past dates via
    `firstDate` is what satisfies `sarprasValidationPastDate`.
  - Name: `AppTextField` with `maxLength: 150`, validator returning
    `l10n.sarprasValidationRequired` when empty.
  - Student count: `AppTextField` with
    `keyboardType: TextInputType.number` and
    `inputFormatters: [FilteringTextInputFormatter.digitsOnly]`. The value is
    submitted as text — never parsed to `int`.
  - Teacher: a `DropdownButtonFormField<String>` fed by
    `BlocBuilder<SarprasTeacherCandidateCubit, ...>`, items mapping
    `candidate.nip` to `Text(candidate.name)`. On `loading` show a disabled
    field with a small progress indicator; on `failure` show
    `l10n.sarprasTeacherLoadFailed` plus a retry `TextButton`; on `empty`
    show `l10n.sarprasTeacherEmpty`.
  - Start and end time: two `InkWell`s calling `showTimePicker`.
  - Note: `AppTextField` with `maxLines: 4`, `maxLength: 500`.
- Submit `AppButton` at the bottom. Its `onPressed` is `null` — which is what
  the first test asserts — when the candidate state is not `success`, or
  when the relevant write cubit is in `loading`.
- `_submit()` validates the form, then checks
  `_end` is strictly after `_start`; if not, `setState` assigns
  `_timeError = l10n.sarprasValidationEndBeforeStart` and returns. The error
  text renders beneath the time row whenever `_timeError != null`.
- On valid input build the params and dispatch:
  ```dart
  final params = SarprasParams(
    tanggalKegiatan: _date!,
    namaKegiatan: _nameController.text,
    jumlahSiswaDalamKegiatan: _countController.text,
    nipGuruPembimbing: _nip!,
    jamMulaiKegiatan: DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _start!.hour,
      _start!.minute,
    ),
    jamSelesaiKegiatan: DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _end!.hour,
      _end!.minute,
    ),
    keterangan: _noteController.text.isEmpty ? null : _noteController.text,
  );
  ```
  Then `context.read<StoreSarprasCubit>().storeSarpras(params)` for create,
  or `context.read<UpdateSarprasCubit>().updateSarpras(sarprasId:
  widget.sarprasId!, params: params)` for edit.
- Two `BlocListener`s handle the outcome: on success show
  `AppToast.success` with `l10n.sarprasCreateSuccess` or
  `l10n.sarprasUpdateSuccess` and `context.pop(true)`; on failure show
  `AppToast.error` and keep the sheet open with the input intact.

- [ ] **Step 4: Add the three sheet routes**

In `lib/core/app_router/app_router.dart`, beside the `/sarpras` route added
in Task 8. Order matters: `/sarpras/new` must be declared before
`/sarpras/:id`, otherwise `new` is captured as an id.

```dart
      GoRoute(
        path: RouteNames.sarprasNew,
        pageBuilder: (context, state) =>
            const CupertinoSheetPage<void>(child: SarprasFormSheet()),
      ),

      GoRoute(
        path: RouteNames.sarprasDetail,
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');

          return CupertinoSheetPage<void>(
            child: SarprasDetailSheet(sarprasId: id ?? -1),
          );
        },
      ),

      GoRoute(
        path: RouteNames.sarprasEdit,
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');

          return CupertinoSheetPage<void>(
            child: SarprasFormSheet(sarprasId: id),
          );
        },
      ),
```

An unparseable id becomes `-1`, which the detail fetch turns into a normal
failure state with retry rather than a crash.

Add the imports:

```dart
import '../../features/sarpras/presentation/screens/sarpras_detail_sheet.dart';
import '../../features/sarpras/presentation/screens/sarpras_form_sheet.dart';
import 'cupertino_sheet_page.dart';
```

- [ ] **Step 5: Run the tests**

Run: `flutter test test/features/sarpras/presentation/screens/sarpras_form_sheet_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 6: Commit**

```bash
dart format . && flutter analyze
git add lib/features/sarpras lib/core/app_router test/features/sarpras
git commit -m "feat(sarpras): add create and edit form sheet"
```

---

### Task 11: Menu entry and full verification

**Files:**
- Modify: `lib/features/dashboard/presentation/widgets/menu_sheet_item.dart`

**Interfaces:**
- Consumes: `RouteNames.sarpras` (Task 8), `l10n.izinSarpras` (Task 4).
- Produces: nothing downstream.

- [ ] **Step 1: Add the menu item**

In `MenuSheetItem.menuItems`, after the `extracurricular` entry:

```dart
    MenuSheetItem(
      icon: Icons.meeting_room_rounded,
      label: 'izinSarpras',
      routePath: RouteNames.sarpras,
    ),
```

- [ ] **Step 2: Add the label branch**

In `resolveLabel`, beside the other cases:

```dart
      case 'izinSarpras':
        return l10n.izinSarpras;
```

- [ ] **Step 3: Verify the whole suite**

```bash
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Expected: format reports 0 changed; analyze reports no issues; the sarpras
tests all pass.

Note: `test/features/attendance/presentation/widgets/attendance_today_section_test.dart`
("shows AppNoData when there is no schedule today") fails on `dev` before
this work starts. Confirm the failure count did not grow — do not try to fix
that test here.

- [ ] **Step 4: Commit**

```bash
git add lib/features/dashboard
git commit -m "feat(sarpras): add dashboard menu entry"
```

---

## Self-Review Notes

Spec coverage checked section by section:

| Spec section | Task |
| --- | --- |
| State management (2 new cubits) | 2, 3 |
| Routing + `CupertinoSheetPage` | 8, 10 |
| List screen, chips, AppSliverGroup | 5, 6, 7 |
| Detail sheet + guarded actions | 9 |
| Form sheet + deep-link guard | 10 |
| `Sarpras.isCancelable` | 1 |
| Localization | 4 |
| Entry point | 11 |
| Testing | folded into each task |

Two areas are described structurally rather than as a single code block:
the detail sheet body (Task 9 Step 3) and the form sheet body (Task 10
Step 3). Both are long composite widgets where a verbatim dump would be
less useful than the field-by-field contract given; every widget, l10n key,
and cubit call they need is named explicitly, and their tests pin the
behaviour that matters.
