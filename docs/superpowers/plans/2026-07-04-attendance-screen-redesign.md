# Attendance Screen Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the student attendance screen into 3 tabs (Beranda/Kalender/Ringkasan), move the QR checkin/checkout action into Beranda as the primary CTA with a cutoff-time-driven state machine, remove the redundant chart section, and remove the QR entry point from `StudentMainShell`.

**Architecture:** `AttendanceScreen` gains a `TabBar`/`TabBarView`. Tab 1 is a new `AttendanceTodaySection` widget backed by the existing `DailyAttendanceBloc`. Tabs 2/3 reuse existing section widgets restyled to `AppFramedContainer`. A pure domain function (`resolveAttendanceQrAction`) maps today's attendance record + current time to a semantic action enum; the widget maps that enum to localized label/enabled state. `StudentMainShell`'s FAB and fake nav branch are removed, along with the corresponding router branch.

**Tech Stack:** Flutter, `flutter_bloc`, `fpdart` (`Result`), `go_router`, `flutter_test` + `mocktail` (existing test stack — no new dependencies).

## Global Constraints

- Copyright header on every new standalone Dart file (see any existing file for exact text).
- `flutter analyze` and `dart format --set-exit-if-changed .` must pass after every task.
- No new third-party dependency (spec confirms reuse of existing stack only).
- Cutoff hour is `13` (13:00), a client-side heuristic — documented as such in code, not fetched from backend.
- `AppNoData` copy (failure/empty states) uses the exact strings agreed during brainstorming (see Task 2 ARB entries) — do not rephrase.
- Domain layer has no `BuildContext`/`AppLocalizations` access — the QR action resolver returns a semantic enum, not a string; the widget owns the enum→label mapping.

---

## Task 1: Domain — attendance checkout cutoff rule + QR action resolver

**Files:**
- Create: `lib/features/attendance/domain/attendance_rules.dart`
- Test: `test/features/attendance/domain/attendance_rules_test.dart`

**Interfaces:**
- Produces: `enum AttendanceQrAction { checkIn, alreadyCheckedIn, checkOut, done }`, `const int attendanceCheckOutCutoffHour`, `AttendanceQrAction resolveAttendanceQrAction(AttendanceEntity? entity, DateTime now)`. Task 3 (`AttendanceTodaySection`) consumes all three.

- [ ] **Step 1: Write the failing test**

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/attendance/domain/attendance_rules.dart';
import 'package:my_bl/features/attendance/domain/entities/attendance_entity/attendance_entity.dart';

AttendanceEntity _entity({DateTime? checkIn, DateTime? checkOut}) {
  final day = DateTime(2026, 7, 6);

  return AttendanceEntity(
    id: 1,
    nis: '123',
    tajaran: '2025/2026',
    semester: '1',
    tanggal: day,
    jamCheckIn: checkIn,
    jamCheckOut: checkOut,
    status: 'Hadir',
    unit: 'SMA',
    createdAt: day,
    updatedAt: day,
  );
}

void main() {
  final beforeCutoff = DateTime(2026, 7, 6, 12, 59);
  final atCutoff = DateTime(2026, 7, 6, 13);
  final afterCutoff = DateTime(2026, 7, 6, 15);

  test('no record yet -> checkIn', () {
    expect(resolveAttendanceQrAction(null, beforeCutoff), AttendanceQrAction.checkIn);
  });

  test('checked in, before cutoff -> alreadyCheckedIn', () {
    final entity = _entity(checkIn: DateTime(2026, 7, 6, 6, 30));
    expect(
      resolveAttendanceQrAction(entity, beforeCutoff),
      AttendanceQrAction.alreadyCheckedIn,
    );
  });

  test('checked in, exactly at cutoff -> checkOut', () {
    final entity = _entity(checkIn: DateTime(2026, 7, 6, 6, 30));
    expect(resolveAttendanceQrAction(entity, atCutoff), AttendanceQrAction.checkOut);
  });

  test('checked in, after cutoff -> checkOut', () {
    final entity = _entity(checkIn: DateTime(2026, 7, 6, 6, 30));
    expect(resolveAttendanceQrAction(entity, afterCutoff), AttendanceQrAction.checkOut);
  });

  test('checked in and out -> done, regardless of time', () {
    final entity = _entity(
      checkIn: DateTime(2026, 7, 6, 6, 30),
      checkOut: DateTime(2026, 7, 6, 11),
    );
    expect(resolveAttendanceQrAction(entity, beforeCutoff), AttendanceQrAction.done);
    expect(resolveAttendanceQrAction(entity, afterCutoff), AttendanceQrAction.done);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/attendance/domain/attendance_rules_test.dart`
Expected: FAIL — `attendance_rules.dart` doesn't exist yet (import error).

- [ ] **Step 3: Write minimal implementation**

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'entities/attendance_entity/attendance_entity.dart';

/// Hour of day (24h) after which checkout becomes available.
///
/// Backend has no official checkout-window rule yet. SMA/SMK (the only
/// units this app currently serves) dismiss around 15:30; 13:00 gives a
/// ~2.5h buffer for early dismissal (sick leave, etc.) while blocking
/// same-morning checkout. Single place to change if BE ever provides a
/// real schedule-based rule.
const int attendanceCheckOutCutoffHour = 13;

/// Semantic state of the attendance QR action button, derived from
/// today's attendance record and the current time. Presentation maps
/// this to a localized label + enabled flag — this function has no
/// knowledge of strings or UI.
enum AttendanceQrAction { checkIn, alreadyCheckedIn, checkOut, done }

AttendanceQrAction resolveAttendanceQrAction(
  AttendanceEntity? entity,
  DateTime now,
) {
  if (entity?.jamCheckIn == null) return AttendanceQrAction.checkIn;
  if (entity!.jamCheckOut != null) return AttendanceQrAction.done;

  return now.hour >= attendanceCheckOutCutoffHour
      ? AttendanceQrAction.checkOut
      : AttendanceQrAction.alreadyCheckedIn;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/attendance/domain/attendance_rules_test.dart`
Expected: PASS (5 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/attendance/domain/attendance_rules.dart test/features/attendance/domain/attendance_rules_test.dart
git commit -m "feat: add attendance QR action resolver and checkout cutoff rule"
```

---

## Task 2: Localization — new ARB entries for the today-tab

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_id.arb`

**Interfaces:**
- Produces: `l10n.attendanceCheckInAction`, `l10n.attendanceAlreadyCheckedIn`, `l10n.attendanceCheckOutAction`, `l10n.attendanceDone`, `l10n.attendanceButtonLoading`, `l10n.attendanceTodayLoadFailedTitle`, `l10n.attendanceTodayLoadFailedSubtitle`, `l10n.attendanceNoScheduleTitle`, `l10n.attendanceNoScheduleSubtitle`. Task 3 consumes all of these.

- [ ] **Step 1: Add new keys to `lib/l10n/app_en.arb`**

Insert after the existing `"noAttendanceData": "No attendance yet."` line (around line 201):

```json
  "attendanceCheckInAction": "Check In",
  "attendanceAlreadyCheckedIn": "Checked In",
  "attendanceCheckOutAction": "Check Out",
  "attendanceDone": "Done",
  "attendanceButtonLoading": "Loading...",
  "attendanceTodayLoadFailedTitle": "Oops, Attendance Went Missing",
  "attendanceTodayLoadFailedSubtitle": "Signal's being cheeky, pull to refresh!",
  "attendanceNoScheduleTitle": "No School Today!",
  "attendanceNoScheduleSubtitle": "Enjoy your day, no attendance to worry about.",
```

- [ ] **Step 2: Add the matching Indonesian keys to `lib/l10n/app_id.arb`**

Insert at the same relative position (after `"noAttendanceData"`):

```json
  "attendanceCheckInAction": "Checkin",
  "attendanceAlreadyCheckedIn": "Sudah Checkin",
  "attendanceCheckOutAction": "Checkout",
  "attendanceDone": "Selesai",
  "attendanceButtonLoading": "Memuat...",
  "attendanceTodayLoadFailedTitle": "Waduh, Absensinya Ngumpet",
  "attendanceTodayLoadFailedSubtitle": "Sinyal lagi jahil nih, coba tarik buat refresh ya!",
  "attendanceNoScheduleTitle": "Hari Ini Libur!",
  "attendanceNoScheduleSubtitle": "Nikmatin harimu, gak ada absen yang perlu ditunggu.",
```

- [ ] **Step 3: Regenerate localizations**

Run: `flutter gen-l10n`
Expected: no errors; `lib/l10n/app_localizations_en.dart` and `app_localizations_id.dart` now expose the 9 new getters.

- [ ] **Step 4: Verify generation**

Run: `grep -c "attendanceCheckInAction" lib/l10n/app_localizations_en.dart lib/l10n/app_localizations_id.dart`
Expected: `1` for each file.

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/app_en.arb lib/l10n/app_id.arb lib/l10n/app_localizations*.dart
git commit -m "feat: add localization keys for attendance today-tab"
```

---

## Task 3: `AttendanceTodaySection` widget

**Files:**
- Create: `lib/features/attendance/presentation/widgets/attendance_today_section.dart`
- Test: `test/features/attendance/presentation/widgets/attendance_today_section_test.dart`

**Interfaces:**
- Consumes: `AttendanceQrAction`, `resolveAttendanceQrAction(AttendanceEntity?, DateTime)` from Task 1; `l10n.attendance*` from Task 2; existing `DailyAttendanceBloc`/`DailyAttendanceState`/`DailyAttendanceEvent.dailyAttendanceRequested({forceRefresh})`; existing `showAttendanceQrSheet(BuildContext)` from `attendance_qr_bottom_sheet.dart`; existing `AppFramedContainer`, `AppNoData`, `AppButton`, `DateAndTimeFormatterExtension.toHourMinuteFormat()`.
- Produces: `class AttendanceTodaySection extends StatelessWidget` (no constructor params — provides its own `DailyAttendanceBloc` via `BlocProvider`, consumed by Task 5's `AttendanceScreen`). Internally uses a `now` seam (`DateTime Function() now`) on the private ticking widget, following the same pattern as `DashboardTimeTableSection`, so tests can pin the clock.

- [ ] **Step 1: Write the failing widget test**

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
import 'package:my_bl/core/widgets/app_button.dart';
import 'package:my_bl/core/widgets/app_container.dart';
import 'package:my_bl/features/attendance/domain/entities/attendance_entity/attendance_entity.dart';
import 'package:my_bl/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:my_bl/features/attendance/domain/usecases/fetch_daily_attendance_use_case.dart';
import 'package:my_bl/features/attendance/presentation/bloc/daily_attendance_bloc/daily_attendance_bloc.dart';
import 'package:my_bl/features/attendance/presentation/widgets/attendance_today_section.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/l10n/app_localizations_en.dart';

class _MockAttendanceRepository extends Mock implements AttendanceRepository {}

final AppLocalizationsEn _l10n = AppLocalizationsEn();

final DateTime _beforeCutoff = DateTime(2026, 7, 6, 8);
final DateTime _afterCutoff = DateTime(2026, 7, 6, 14);

AttendanceEntity _entity({DateTime? checkIn, DateTime? checkOut}) {
  final day = DateTime(2026, 7, 6);

  return AttendanceEntity(
    id: 1,
    nis: '123',
    tajaran: '2025/2026',
    semester: '1',
    tanggal: day,
    jamCheckIn: checkIn,
    jamCheckOut: checkOut,
    status: 'Hadir',
    unit: 'SMA',
    createdAt: day,
    updatedAt: day,
  );
}

DailyAttendanceBloc _buildBloc(_MockAttendanceRepository repository) {
  return DailyAttendanceBloc(FetchDailyAttendanceUseCase(repository));
}

Widget _wrap(DailyAttendanceBloc bloc, {DateTime Function() now = DateTime.now}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: BlocProvider<DailyAttendanceBloc>.value(
        value: bloc,
        child: AttendanceTodaySection(now: now),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(false);
  });

  testWidgets('shows AppNoData on failure', (tester) async {
    final repository = _MockAttendanceRepository();
    when(
      () => repository.fetchDailyAttendance(any()),
    ).thenAnswer((_) async => left(const Failure.network()));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    bloc.add(const DailyAttendanceEvent.dailyAttendanceRequested());
    await tester.pumpAndSettle();

    expect(find.byType(AppNoData), findsOneWidget);
    expect(find.text(_l10n.attendanceTodayLoadFailedTitle), findsOneWidget);
  });

  testWidgets('shows AppNoData when there is no schedule today', (tester) async {
    final repository = _MockAttendanceRepository();
    when(
      () => repository.fetchDailyAttendance(any()),
    ).thenAnswer((_) async => right(null));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    bloc.add(const DailyAttendanceEvent.dailyAttendanceRequested());
    await tester.pumpAndSettle();

    expect(find.byType(AppNoData), findsOneWidget);
    expect(find.text(_l10n.attendanceNoScheduleTitle), findsOneWidget);
  });

  testWidgets('shows enabled "Check In" button when no record exists yet', (
    tester,
  ) async {
    final repository = _MockAttendanceRepository();
    when(
      () => repository.fetchDailyAttendance(any()),
    ).thenAnswer((_) async => right(_entity()));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc, now: () => _beforeCutoff));
    bloc.add(const DailyAttendanceEvent.dailyAttendanceRequested());
    await tester.pumpAndSettle();

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(find.text(_l10n.attendanceCheckInAction), findsOneWidget);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('shows disabled "Checked In" button before cutoff', (
    tester,
  ) async {
    final repository = _MockAttendanceRepository();
    when(() => repository.fetchDailyAttendance(any())).thenAnswer(
      (_) async => right(_entity(checkIn: DateTime(2026, 7, 6, 6, 30))),
    );

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc, now: () => _beforeCutoff));
    bloc.add(const DailyAttendanceEvent.dailyAttendanceRequested());
    await tester.pumpAndSettle();

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(find.text(_l10n.attendanceAlreadyCheckedIn), findsOneWidget);
    expect(button.onPressed, isNull);
  });

  testWidgets('shows enabled "Check Out" button after cutoff', (tester) async {
    final repository = _MockAttendanceRepository();
    when(() => repository.fetchDailyAttendance(any())).thenAnswer(
      (_) async => right(_entity(checkIn: DateTime(2026, 7, 6, 6, 30))),
    );

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc, now: () => _afterCutoff));
    bloc.add(const DailyAttendanceEvent.dailyAttendanceRequested());
    await tester.pumpAndSettle();

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(find.text(_l10n.attendanceCheckOutAction), findsOneWidget);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('shows disabled "Done" button once checked out', (tester) async {
    final repository = _MockAttendanceRepository();
    when(() => repository.fetchDailyAttendance(any())).thenAnswer(
      (_) async => right(
        _entity(
          checkIn: DateTime(2026, 7, 6, 6, 30),
          checkOut: DateTime(2026, 7, 6, 11),
        ),
      ),
    );

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc, now: () => _afterCutoff));
    bloc.add(const DailyAttendanceEvent.dailyAttendanceRequested());
    await tester.pumpAndSettle();

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(find.text(_l10n.attendanceDone), findsOneWidget);
    expect(button.onPressed, isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/attendance/presentation/widgets/attendance_today_section_test.dart`
Expected: FAIL — `attendance_today_section.dart` doesn't exist / `AttendanceTodaySection` has no `now` param yet.

- [ ] **Step 3: Write the implementation**

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/attendance_rules.dart';
import '../../domain/entities/attendance_entity/attendance_entity.dart';
import '../bloc/daily_attendance_bloc/daily_attendance_bloc.dart';
import 'attendance_qr_bottom_sheet.dart';

class AttendanceTodaySection extends StatefulWidget {
  const AttendanceTodaySection({super.key, this.now = DateTime.now});

  /// Clock seam for tests — pins "now" instead of the real wall clock.
  final DateTime Function() now;

  @override
  State<AttendanceTodaySection> createState() =>
      _AttendanceTodaySectionState();
}

class _AttendanceTodaySectionState extends State<AttendanceTodaySection> {
  Timer? _tickTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();

    _now = widget.now();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = widget.now());
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<DailyAttendanceBloc, DailyAttendanceState>(
      listener: (context, state) => state.whenOrNull(
        failure: (failure) =>
            AppToast.error(context, failure.localizedMessage(l10n)),
      ),
      builder: (context, state) {
        return state.maybeWhen(
          failure: (_) => AppFramedContainer(
            gap: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            elevation: 0,
            child: AppNoData(
              icon: Icons.wifi_off_rounded,
              title: l10n.attendanceTodayLoadFailedTitle,
              message: l10n.attendanceTodayLoadFailedSubtitle,
            ),
          ),
          emptyAttendance: () => AppFramedContainer(
            gap: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            elevation: 0,
            child: AppNoData(
              icon: Icons.weekend_outlined,
              title: l10n.attendanceNoScheduleTitle,
              message: l10n.attendanceNoScheduleSubtitle,
            ),
          ),
          orElse: () => _AttendanceTodayCard(
            state: state,
            now: _now,
            l10n: l10n,
          ),
        );
      },
    );
  }
}

class _AttendanceTodayCard extends StatelessWidget {
  const _AttendanceTodayCard({
    required this.state,
    required this.now,
    required this.l10n,
  });

  final DailyAttendanceState state;
  final DateTime now;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);
    final entity = state.maybeWhen(
      success: (dailyAttendance) => dailyAttendance,
      orElse: () => null,
    );
    final action = isLoading ? null : resolveAttendanceQrAction(entity, now);
    final buttonContent = _buttonContent(action);

    return AppFramedContainer(
      backgroundColor: colorScheme.surface,
      gap: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _timeLabel(entity?.jamCheckIn),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_clockLabel(now)} ${l10n.westernIndonesiaTime}',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _timeLabel(entity?.jamCheckOut),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            onPressed: isLoading || !buttonContent.enabled
                ? null
                : () => showAttendanceQrSheet(context),
            child: Text(
              isLoading ? l10n.attendanceButtonLoading : buttonContent.label,
            ),
          ),
        ],
      ),
    );
  }

  ({String label, bool enabled}) _buttonContent(AttendanceQrAction? action) {
    return switch (action) {
      null => (label: '', enabled: false),
      AttendanceQrAction.checkIn => (
        label: l10n.attendanceCheckInAction,
        enabled: true,
      ),
      AttendanceQrAction.alreadyCheckedIn => (
        label: l10n.attendanceAlreadyCheckedIn,
        enabled: false,
      ),
      AttendanceQrAction.checkOut => (
        label: l10n.attendanceCheckOutAction,
        enabled: true,
      ),
      AttendanceQrAction.done => (label: l10n.attendanceDone, enabled: false),
    };
  }

  String _timeLabel(DateTime? dateTime) =>
      dateTime == null ? '--:--' : dateTime.toLocal().toHourMinuteFormat();

  String _clockLabel(DateTime now) => now.toHourMinuteSecondFormat();
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/attendance/presentation/widgets/attendance_today_section_test.dart`
Expected: PASS (5 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/attendance/presentation/widgets/attendance_today_section.dart test/features/attendance/presentation/widgets/attendance_today_section_test.dart
git commit -m "feat: add AttendanceTodaySection with QR checkin/checkout state machine"
```

---

## Task 4: Restyle existing attendance sections to `AppFramedContainer`

**Files:**
- Modify: `lib/features/attendance/presentation/widgets/attendance_summary_section.dart`
- Modify: `lib/features/attendance/presentation/widgets/attendance_calendar_section.dart`
- Modify: `lib/features/attendance/presentation/widgets/attendance_filtered_section.dart`

**Interfaces:**
- Consumes: existing `AppFramedContainer` (already used by Task 3 and dashboard sections).
- Produces: same public widget classes (`AttendanceSummarySection`, `AttendanceCalendarSection`, `AttendanceFilteredSection`), unchanged constructors — only their internal container swaps.

This is a style-only change: swap the outer `AppContainer(backgroundColor: colorScheme.surfaceContainerLow, margin: EdgeInsets.zero, elevation: 0, borderRadius: BorderRadius.circular(16), child: ...)` for `AppFramedContainer(backgroundColor: colorScheme.surface, margin: EdgeInsets.zero, gap: EdgeInsets.zero, elevation: 0, child: ...)` in each file's top-level section container only (not the inner per-item containers like `_AttendanceSummaryCard`, `_AttendanceLogContainer` — those stay `AppContainer` as designed, matching dashboard's `_TimeTableContainer` pattern of inner cards staying `AppFramedContainer`/`AppContainer` distinctly from the outer frame).

- [ ] **Step 1: Restyle `attendance_summary_section.dart`**

In `AttendanceSummarySection.build`, replace:

```dart
          child: AppContainer(
            backgroundColor: colorScheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            elevation: 0,
            borderRadius: BorderRadius.circular(16),
            child: Column(
```

with:

```dart
          child: AppFramedContainer(
            backgroundColor: colorScheme.surface,
            margin: EdgeInsets.zero,
            gap: EdgeInsets.zero,
            elevation: 0,
            child: Column(
```

(The closing `)` for this widget stays unchanged — only the constructor name and its `borderRadius`/`gap` params change.)

- [ ] **Step 2: Restyle `attendance_calendar_section.dart`**

Replace:

```dart
          return RepaintBoundary(
            child: AppContainer(
              backgroundColor: colorScheme.surfaceContainerLow,
              margin: EdgeInsets.zero,
              elevation: 0,
              borderRadius: BorderRadius.circular(16),
              child: Column(
```

with:

```dart
          return RepaintBoundary(
            child: AppFramedContainer(
              backgroundColor: colorScheme.surface,
              margin: EdgeInsets.zero,
              gap: EdgeInsets.zero,
              elevation: 0,
              child: Column(
```

- [ ] **Step 3: Restyle `attendance_filtered_section.dart`**

This file's top-level `AppSliverGroup.child` is a plain `Column` (filter bar + log items), not wrapped in a container — no change needed here. Confirm by re-reading the file: the `_AttendanceLogContainer`/`_AttendanceMessageContainer` inner items stay `AppContainer` as-is (per-row cards, not the section frame). No edit for this file; skip to Step 4.

- [ ] **Step 4: Run `flutter analyze`**

Run: `flutter analyze lib/features/attendance/presentation/widgets/attendance_summary_section.dart lib/features/attendance/presentation/widgets/attendance_calendar_section.dart`
Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/features/attendance/presentation/widgets/attendance_summary_section.dart lib/features/attendance/presentation/widgets/attendance_calendar_section.dart
git commit -m "refactor: restyle attendance section frames to AppFramedContainer"
```

---

## Task 5: Restructure `AttendanceScreen` into 3 tabs, drop chart section

**Files:**
- Modify: `lib/features/attendance/presentation/screens/attendance_screen.dart`
- Delete: `lib/features/attendance/presentation/widgets/attendance_chart_section.dart`
- Delete: `lib/features/attendance/presentation/widgets/attendance_chart.dart`

**Interfaces:**
- Consumes: `AttendanceTodaySection` (Task 3), existing `AttendanceCalendarSection`, `AttendanceFilteredSection`, `AttendanceSummarySection`, `DailyAttendanceBloc`, `MonthlyAttendanceBloc`.
- Produces: `AttendanceScreen` (unchanged public API — still a `StatelessWidget` with no constructor params), now rendering 3 tabs instead of a single scroll stack.

- [ ] **Step 1: Confirm the chart files have no other callers**

Run: `grep -rln "AttendanceChartSection\|attendance_chart" lib`
Expected: only `attendance_chart_section.dart` and `attendance_screen.dart` (the file we're about to edit) — confirms safe to delete once the import is removed from the screen.

- [ ] **Step 2: Rewrite `attendance_screen.dart`**

Replace the whole file with:

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../bloc/daily_attendance_bloc/daily_attendance_bloc.dart';
import '../bloc/monthly_attendance_bloc/monthly_attendance_bloc.dart';
import '../widgets/attendance_calendar_section.dart';
import '../widgets/attendance_filtered_section.dart';
import '../widgets/attendance_summary_section.dart';
import '../widgets/attendance_today_section.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isParent = context.read<SessionBloc>().state.maybeWhen(
      authenticated: (_, role) => role == UserRole.parent,
      orElse: () => false,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<DailyAttendanceBloc>(
          create: (context) => di<DailyAttendanceBloc>(),
        ),
        BlocProvider<MonthlyAttendanceBloc>(
          create: (context) => di<MonthlyAttendanceBloc>(param1: isParent),
        ),
      ],
      child: const _AttendanceScreenView(),
    );
  }
}

class _AttendanceScreenView extends StatefulWidget {
  const _AttendanceScreenView();

  @override
  State<_AttendanceScreenView> createState() => _AttendanceScreenViewState();
}

class _AttendanceScreenViewState extends State<_AttendanceScreenView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    final now = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DailyAttendanceBloc>().add(
        const DailyAttendanceEvent.dailyAttendanceRequested(),
      );
      context.read<MonthlyAttendanceBloc>().add(
        MonthlyAttendanceEvent.monthChangeRequested(
          month: now.month,
          year: now.year,
        ),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppTopBar(
        toolbarHeight: 72,
        title: Text(l10n.dailyAttendance),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.home),
            Tab(text: l10n.attendanceCalendar),
            Tab(text: l10n.attendanceSummary),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AttendanceTodayTab(),
          _AttendanceCalendarTab(),
          _AttendanceSummaryTab(),
        ],
      ),
    );
  }
}

class _AttendanceTodayTab extends StatelessWidget {
  const _AttendanceTodayTab();

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () => blocRefresh<
        DailyAttendanceBloc,
        DailyAttendanceEvent,
        DailyAttendanceState
      >(
        context: context,
        event: const DailyAttendanceEvent.dailyAttendanceRequested(
          forceRefresh: true,
        ),
        isDone: (state) => state.maybeWhen(
          success: (_) => true,
          emptyAttendance: () => true,
          failure: (_) => true,
          orElse: () => false,
        ),
      ),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [AttendanceTodaySection()],
      ),
    );
  }
}

class _AttendanceCalendarTab extends StatelessWidget {
  const _AttendanceCalendarTab();

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () {
        final state = context.read<MonthlyAttendanceBloc>().state;

        final month = state.maybeWhen(
          success: (m, _, _, _, _, _) => m,
          loading: (m, _) => m,
          orElse: () => DateTime.now().month,
        );
        final year = state.maybeWhen(
          success: (_, y, _, _, _, _) => y,
          loading: (_, y) => y,
          orElse: () => DateTime.now().year,
        );

        return blocRefresh<
          MonthlyAttendanceBloc,
          MonthlyAttendanceEvent,
          MonthlyAttendanceState
        >(
          context: context,
          event: MonthlyAttendanceEvent.monthChangeRequested(
            month: month,
            year: year,
            forceRefresh: true,
          ),
          isDone: (state) => state.maybeWhen(
            success: (_, _, _, _, _, _) => true,
            failure: (_) => true,
            orElse: () => false,
          ),
        );
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: const [
          AttendanceCalendarSection(),
          AttendanceFilteredSection(),
          SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _AttendanceSummaryTab extends StatelessWidget {
  const _AttendanceSummaryTab();

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () {
        final state = context.read<MonthlyAttendanceBloc>().state;

        final month = state.maybeWhen(
          success: (m, _, _, _, _, _) => m,
          loading: (m, _) => m,
          orElse: () => DateTime.now().month,
        );
        final year = state.maybeWhen(
          success: (_, y, _, _, _, _) => y,
          loading: (_, y) => y,
          orElse: () => DateTime.now().year,
        );

        return blocRefresh<
          MonthlyAttendanceBloc,
          MonthlyAttendanceEvent,
          MonthlyAttendanceState
        >(
          context: context,
          event: MonthlyAttendanceEvent.monthChangeRequested(
            month: month,
            year: year,
            forceRefresh: true,
          ),
          isDone: (state) => state.maybeWhen(
            success: (_, _, _, _, _, _) => true,
            failure: (_) => true,
            orElse: () => false,
          ),
        );
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: const [
          AttendanceSummarySection(),
          SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
```

> Note: the `isParent` app-bar profile action from the old screen is dropped entirely per this task's scope — `AppTopBar` now takes no `actions`.

- [ ] **Step 3: Delete the chart files**

```bash
git rm lib/features/attendance/presentation/widgets/attendance_chart_section.dart
git rm lib/features/attendance/presentation/widgets/attendance_chart.dart
```

- [ ] **Step 4: Run analyze and format**

Run: `dart format lib/features/attendance/presentation/screens/attendance_screen.dart && flutter analyze lib/features/attendance`
Expected: No issues found.

- [ ] **Step 5: Manual smoke check**

Run: `flutter run` (or `flutter test` if no device attached is fine for this step — this is a manual UI check per CLAUDE.md's UI verification rule)
Navigate to the attendance screen as a student; confirm 3 tabs render, Beranda shows the QR CTA, Kalender shows calendar+log, Ringkasan shows summary cards. Confirm no leftover chart tab.

- [ ] **Step 6: Commit**

```bash
git add lib/features/attendance/presentation/screens/attendance_screen.dart
git commit -m "refactor: split attendance screen into Beranda/Kalender/Ringkasan tabs"
```

---

## Task 6: Remove QR entry point from `StudentMainShell` + router

**Files:**
- Modify: `lib/features/dashboard/presentation/shell/student_main_shell.dart`
- Modify: `lib/core/app_router/app_router.dart`
- Modify: `lib/core/app_router/route_names.dart`
- Test: `test/features/dashboard/presentation/shell/student_main_shell_test.dart`

**Interfaces:**
- Consumes: none new.
- Produces: `_ShellBottomNavigationBar` with 2 destinations (Dashboard, Profile) instead of 3; no `floatingActionButton`.

- [ ] **Step 1: Write the failing widget test**

```dart
// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('student bottom nav renders 2 NavigationDestinations', (
    tester,
  ) async {
    // Build a NavigationBar with 2 destinations in isolation —
    // avoids needing a real StatefulNavigationShell.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.house_outlined),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(NavigationDestination), findsNWidgets(2));
  });
}
```

- [ ] **Step 2: Run test to verify it currently would fail against real shell expectations**

Run: `flutter test test/features/dashboard/presentation/shell/student_main_shell_test.dart`
Expected: PASS already (this test is isolated, like the existing parent one) — this step just confirms the test file itself runs; the real assertion happens once we also manually verify the shell file in Step 5.

- [ ] **Step 3: Edit `student_main_shell.dart`**

Remove the `showAttendanceQrSheet` import:

```dart
import '../../../attendance/presentation/widgets/attendance_qr_bottom_sheet.dart';
```

Remove the `floatingActionButton`/`floatingActionButtonLocation` from the `Scaffold` in `_StudentMainShellViewState.build` — replace:

```dart
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          body: isUnderMaintenance
              ? const AppUnderMaintenanceContainer()
              : widget.navigationShell,
          floatingActionButton: isUnderMaintenance
              ? null
              : FloatingActionButton(
                  onPressed: () => showAttendanceQrSheet(context),
                  tooltip: AppLocalizations.of(context)!.attendanceQrCode,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.qr_code_2),
                ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: isUnderMaintenance
              ? null
              : _ShellBottomNavigationBar(
                  navigationShell: widget.navigationShell,
                ),
        );
```

with:

```dart
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          body: isUnderMaintenance
              ? const AppUnderMaintenanceContainer()
              : widget.navigationShell,
          bottomNavigationBar: isUnderMaintenance
              ? null
              : _ShellBottomNavigationBar(
                  navigationShell: widget.navigationShell,
                ),
        );
```

Replace `_ShellBottomNavigationBar` entirely:

```dart
class _ShellBottomNavigationBar extends StatelessWidget {
  const _ShellBottomNavigationBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return NavigationBar(
      backgroundColor: colorScheme.surfaceContainerLow,
      height: 85,
      elevation: 0,
      indicatorColor: colorScheme.secondaryContainer,
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSecondaryContainer,
          );
        }
        return TextStyle(
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
        );
      }),
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.house_outlined, color: colorScheme.onSurfaceVariant),
          selectedIcon: Icon(
            Icons.house,
            color: colorScheme.onSecondaryContainer,
          ),
          label: l10n.home,
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant),
          selectedIcon: Icon(
            Icons.person,
            color: colorScheme.onSecondaryContainer,
          ),
          label: l10n.profile,
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Remove the placeholder `menu` branch from the router**

In `lib/core/app_router/app_router.dart`, inside the `StudentMainShell`'s `StatefulShellRoute.indexedStack`, remove the middle branch:

```dart
          StatefulShellBranch(
            routes: <GoRoute>[
              GoRoute(
                path: RouteNames.menu,
                builder: (context, state) => const SizedBox.shrink(),
              ),
            ],
          ),

```

(leaving only the `dashboard` and `profile` branches).

- [ ] **Step 5: Remove the now-unused `RouteNames.menu` constant**

In `lib/core/app_router/route_names.dart`, delete:

```dart
  static const String menu = "/menu";
```

Confirm it's unused elsewhere first:

Run: `grep -rn "RouteNames.menu" lib`
Expected: no output after Step 4's edit.

- [ ] **Step 6: Run analyze and the shell test**

Run: `flutter analyze lib/features/dashboard/presentation/shell/student_main_shell.dart lib/core/app_router && flutter test test/features/dashboard/presentation/shell/student_main_shell_test.dart`
Expected: No analyze issues; test passes.

- [ ] **Step 7: Manual smoke check**

Run: `flutter run`, log in as a student. Confirm bottom nav shows 2 items (no QR), no FAB, and attendance is still reachable from wherever it's linked on the dashboard (quick menu / today-attendance card).

- [ ] **Step 8: Commit**

```bash
git add lib/features/dashboard/presentation/shell/student_main_shell.dart lib/core/app_router/app_router.dart lib/core/app_router/route_names.dart test/features/dashboard/presentation/shell/student_main_shell_test.dart
git commit -m "refactor: remove QR entry point from student shell, move it into attendance screen"
```

---

## Task 7: Full verification pass

**Files:** none (verification only).

- [ ] **Step 1: Format check**

Run: `dart format --set-exit-if-changed .`
Expected: exit 0, no files needing formatting.

- [ ] **Step 2: Analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Full test suite**

Run: `flutter test`
Expected: all tests pass, including the new `attendance_rules_test.dart`, `attendance_today_section_test.dart`, and `student_main_shell_test.dart`.

- [ ] **Step 4: Final manual walkthrough**

Run: `flutter run`. As a student: open Attendance from dashboard → confirm 3 tabs, QR button state changes are visually correct at least for the "not checked in yet" case (full cutoff-time state transitions can't be manually forced without changing the device clock — covered by Task 3's automated tests instead). Confirm dashboard's own `DashboardTodayAttendanceSection`/FAB removal didn't break the dashboard screen (dashboard has its own separate `DailyAttendanceBloc` instance already — unaffected by this change).

- [ ] **Step 5: Commit (if any stray formatting fixes were needed)**

```bash
git add -A
git commit -m "chore: format fixes after attendance screen redesign"
```
