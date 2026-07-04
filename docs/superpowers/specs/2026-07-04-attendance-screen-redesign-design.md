# Attendance Screen Redesign — Design Spec

Date: 2026-07-04

## Background

Current `attendance_screen.dart` stacks 4 sections vertically (summary cards + progress bar, calendar, filtered log, chart). Present/late/excused/absent breakdown is shown 3 times (cards, progress bar, chart) — redundant, no clear hierarchy, long scroll before reaching the log.

Separately, `StudentMainShell` has a QR-code FAB + fake bottom-nav destination that opens `showAttendanceQrSheet` (student's checkin/checkout QR, scanned by guru piket). This is disconnected from the attendance screen despite being the same domain.

## Goals

- Split attendance screen into 3 tabs, each one clear mental model: Beranda (today's status + QR action), Kalender (calendar + log), Ringkasan (summary stats).
- Move the QR checkin/out action into the attendance screen as the primary CTA, with a client-side state machine (Checkin / Sudah Checkin / Checkout / Selesai) driven by today's attendance record + a checkout cutoff time.
- Remove the now-redundant chart section and the QR entry point from `StudentMainShell`.

## Non-goals

- No backend changes. Cutoff time (13:00) is a client-side-only heuristic pending a real BE rule; tracked as a known gap, not solved here.
- No change to `AttendanceQrBloc` / `showAttendanceQrSheet` internals — reused as-is.
- No change to parent-facing attendance screens (this redesign is student-only; parent variant out of scope).

## Design

### Screen structure

`AttendanceScreen` becomes `Scaffold` + `AppTopBar` (title only, no profile action — matches dashboard's use of `AppTopBar`, drop `_AttendanceProfileAction`/`isParent` branch entirely) + `TabBar` + `TabBarView`, 3 tabs:

1. **Beranda** (default/first tab) — new `AttendanceTodaySection` widget.
2. **Kalender** — existing `AttendanceCalendarSection` + `AttendanceFilteredSection`, moved here unchanged internally.
3. **Ringkasan** — existing `AttendanceSummarySection`, unchanged internally. `AttendanceChartSection` and `attendance_chart.dart` are deleted (redundant with cards + calendar).

Each tab keeps a `CustomScrollView` + `RefreshWrapper`, per existing screen conventions.

Sections restyle from `AppContainer` to `AppFramedContainer` (dashboard's per-section container: `backgroundColor: colorScheme.surface`, `margin: .zero`, `gap: .zero`, `elevation: 0`) to match dashboard's visual language.

### AttendanceTodaySection (new)

Location: `lib/features/attendance/presentation/widgets/attendance_today_section.dart`.

`BlocProvider<DailyAttendanceBloc>(create: (_) => di<DailyAttendanceBloc>())` (factory, existing registration, screen-scoped instance — same pattern as `MonthlyAttendanceBloc` already in this screen) → `BlocConsumer` (toast on failure) + `AppFramedContainer` hero card.

Hero card contents: check-in time / check-out time (or `--:--` placeholders), live clock (`HH:mm:ss`) + "WIB" label, QR CTA button below (thumb zone).

Live clock: small private `StatefulWidget` inside this file, `Stream.periodic(Duration(seconds: 1))` — pure UI ticking, no business logic, per CLAUDE.md's "business logic never in widgets" (this is a display concern, not a rule).

### QR button state machine

Pure function `_qrButtonState(AttendanceEntity? entity, DateTime now) → ({String label, bool enabled})`, private top-level helper in `attendance_today_section.dart` (presentation-only transformation, no domain logic — mirrors existing `_attendanceStatusStyle`/`_attendanceStatusLabel` pattern in `attendance_filtered_section.dart`).

Cutoff constant: `attendanceCheckoutCutoffHour = 13` in new `lib/features/attendance/domain/attendance_rules.dart`, with a comment explaining it's a stopgap (SMA/SMK dismissal ~15:30, no official BE rule yet, 2.5h buffer for early dismissal/sick leave).

| `DailyAttendanceState` | `jamCheckIn` | `jamCheckOut` | `now` vs cutoff | Card content |
|---|---|---|---|---|
| `initial` / `loading` | – | – | – | Shimmer hero, button disabled "Memuat..." |
| `failure` | – | – | – | `AppNoData(icon: Icons.wifi_off_rounded, title: "Waduh, Absensinya Ngumpet", message: "Sinyal lagi jahil nih, coba tarik buat refresh ya!")` — no button |
| `emptyAttendance` | – | – | – | `AppNoData(icon: Icons.weekend_outlined, title: "Hari Ini Libur!", message: "Nikmatin harimu, gak ada absen yang perlu ditunggu.")` — no button |
| `success` | `null` | – | – | Button: "Checkin", enabled |
| `success` | set | `null` | `< 13:00` | Button: "Sudah Checkin", disabled |
| `success` | set | `null` | `≥ 13:00` | Button: "Checkout", enabled |
| `success` | set | set | – | Button: "Selesai", disabled |

Both `AppNoData` copy strings need new `AppLocalizations` (ARB) entries (title/subtitle pairs), following the fun-but-not-overly-slangy tone established above.

Button tap (when enabled) → `showAttendanceQrSheet(context)` (unchanged).

### StudentMainShell changes

Remove: FAB (`floatingActionButton`), fake QR `NavigationDestination` + its intercept branch in `_onTabTapped`, `floatingActionButtonLocation`, the `showAttendanceQrSheet` import. Bottom nav becomes a plain 2-destination shell (Dashboard, Profile) matching the real routed branches.

### Data flow / DI

- `DailyAttendanceBloc` already `registerFactory` in `attendance_di.dart` — reused, no DI file changes.
- `_AttendanceScreenViewState.initState()`: add `dailyAttendanceRequested()` dispatch alongside the existing `monthChangeRequested()` call in the same `addPostFrameCallback`.
- Tab 1's refresh wrapper adds `blocRefresh<DailyAttendanceBloc, DailyAttendanceEvent, DailyAttendanceState>` with `dailyAttendanceRequested(forceRefresh: true)`, `isDone` matching dashboard's existing pattern (`success`/`emptyAttendance`/`failure`).
- Delete `attendance_chart_section.dart` + `attendance_chart.dart` after confirming (via grep) no other callers.

### Testing

- Unit test: `_qrButtonState(entity, now)` — table-driven (`package:test` + `package:checks`), covers all 7 rows above including the exact-13:00 boundary.
- Widget test: `AttendanceTodaySection` — fake `DailyAttendanceBloc` states (loading / each success variant / failure / emptyAttendance) → assert correct button label/enabled and `AppNoData` copy.
- Widget test: `StudentMainShell` — update/remove any existing assertion referencing the FAB or 3rd nav destination.
- No `build_runner` regen needed — no new `@freezed`/`fromJson` types (`attendance_rules.dart` is a plain top-level const).

## Open questions / risks

- Cutoff time (13:00) is a heuristic, not backend-driven — if BE later adds a real schedule-based rule, this constant becomes the single place to swap for a fetched value.
- Deleting the chart requires confirming no other screen imports `attendance_chart.dart`/`AttendanceChartSection` first.
