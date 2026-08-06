# Sarpras UI — Design

Date: 2026-07-22
Status: approved for planning

## Purpose

Give students a way to request use of school facilities (izin sarpras), see
where each request stands, and correct or withdraw a request while it is
still pending.

The data layer already exists and is verified against the live SPO API
(commit `e475c61`). This design covers only the presentation layer.

## Scope

Full CRUD: list, detail, create, edit, cancel.

**Student role only.** Parent users do not see the feature at all — no menu
entry, no route. The sarpras endpoints have not been verified against a
parent session, and an unexpected 401 force-logs the user out.

Out of scope: approval/rejection flows (those belong to Kesiswaan staff, not
this app), notifications on status change, attachments.

## State management

One Bloc for data, one Cubit per write action. Existing classes are reused;
two cubits are new.

| Class | Status | Responsibility |
| --- | --- | --- |
| `SarprasBloc` | exists | Fetch list + summary |
| `StoreSarprasCubit` | exists | Submit new request |
| `UpdateSarprasCubit` | exists | Submit edit |
| `DestroySarprasCubit` | exists | Cancel request |
| `DetailSarprasCubit` | **new** | Fetch one request for the detail sheet |
| `SarprasTeacherCandidateCubit` | **new** | Fetch supervising-teacher options |

Each cubit owns its own lifecycle. Submitting a form must not emit loading on
`SarprasBloc` — the list screen sits behind the form sheet and would drop its
loaded data and rebuild to a spinner.

After a write succeeds, a `BlocListener` on the list screen dispatches
`SarprasEvent.fetchSarpras()`. That is the only refresh path; no local list
mutation, so the summary counts stay consistent with the server.

Filter-chip selection is local widget state, not a Cubit. It is UI logic with
no business rule and nothing outside the screen needs it.

## Files

```
lib/features/sarpras/
├── domain/entities/sarpras/sarpras.dart      (modified — add isCancelable)
├── presentation/
│   ├── cubit/
│   │   ├── detail_sarpras_cubit.dart          + _state.dart
│   │   └── sarpras_teacher_candidate_cubit.dart + _state.dart
│   ├── screens/
│   │   ├── sarpras_screen.dart
│   │   ├── sarpras_detail_sheet.dart
│   │   └── sarpras_form_sheet.dart
│   └── widgets/
│       ├── sarpras_summary_chips.dart
│       ├── sarpras_list_item.dart
│       └── sarpras_status_badge.dart
└── sarpras_di.dart                            (modified — register 2 cubits)

lib/core/app_router/
├── route_names.dart                           (modified — 4 route names)
├── app_router.dart                            (modified — 4 routes)
└── cupertino_sheet_page.dart                  (new — Page → CupertinoSheetRoute)

lib/features/dashboard/presentation/widgets/menu_sheet_item.dart  (modified)
lib/l10n/app_en.arb, app_id.arb                (modified)
```

## Routing

| Route name | Path | Presentation |
| --- | --- | --- |
| `sarpras` | `/sarpras` | Pushed screen |
| `sarprasNew` | `/sarpras/new` | Cupertino sheet |
| `sarprasDetail` | `/sarpras/:id` | Cupertino sheet |
| `sarprasEdit` | `/sarpras/:id/edit` | Cupertino sheet |

Sheets go through go_router, not `Navigator.push`. `CupertinoSheetRoute`
extends `PageRoute` and accepts `settings`, so a small `Page` subclass wires
it in:

```dart
class CupertinoSheetPage<T> extends Page<T> {
  const CupertinoSheetPage({required this.child, super.key, super.name});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) =>
      CupertinoSheetRoute<T>(builder: (_) => child, settings: this);
}
```

This keeps the sheets deep-linkable and keeps redirect logic in one place.
Edit opens as a sheet stacked on top of the detail sheet;
`CupertinoSheetRoute` is designed to stack.

`:id` is parsed with `int.tryParse`. A non-numeric or unknown id shows the
sheet's failure state with a retry action rather than throwing.

## Screens

### List — `/sarpras`

`AppTopBar` titled "Izin Sarpras". `RefreshWrapper` wrapping a
`CustomScrollView`, following `merit_demerit_screen.dart`.

Slivers, in order:

1. **Summary chips** — `AppChipContainer`, four chips: Semua, Menunggu,
   Disetujui, Ditolak. Counts come from the API `ringkasan`; the "Semua"
   count is the sum. A chip whose count is 0 stays visible but disabled, so
   chip positions never shift between refreshes.
2. **List** — an `AppSliverGroup` titled "Riwayat Pengajuan", with a
   `SliverList.builder` in its `sliver` slot. Each item shows activity name
   as title, date plus `waktu_kegiatan` beneath, and a status badge trailing.

`AppSliverGroup` composes a `SliverMainAxisGroup` of its header plus
`SliverPadding(padding: contentPadding, sliver: ...)`, and `contentPadding`
already defaults to 16 horizontal / 8 vertical. List items must not add their
own horizontal padding or the content ends up inset twice.

The group's `action` slot stays unused; the chips above already carry the
counts.

The shimmer, empty, and populated bodies all go in the group's `sliver` slot,
so the section header stays put while the body swaps. Only `failure` renders
outside the group — there is no section to head when nothing loaded.

Badge colours come from `AppColors.of(context)`: `warning` for Menunggu,
`success` for Disetujui, `error` for Ditolak. No hardcoded colours.

Dates render through the existing `toDayDateMonthYearFormat(context)`
extension, which calls `toLocal()`. The backend returns
`tanggal_kegiatan` as midnight WIB expressed in UTC, so any renderer that
skips `toLocal()` shows the previous day.

Empty states use `AppEmptyStateSliver` with two distinct messages: nothing
submitted yet, versus filter active with no matches. Collapsing these into
one message reads as data loss.

One primary CTA: a FAB labelled "Ajukan", bottom-right, in the thumb zone.

State handling:

| State | Chips | Body |
| --- | --- | --- |
| `initial`, `loading` | hidden | Shimmer list via `toShimmer()`, inside the group |
| `failure` | hidden | `AppEmptyStateSliver` with retry, outside the group |
| `empty` | shown (all zero) | Empty state inside the group |
| `success` | shown | Filtered list inside the group |

Chips are hidden in `loading` and `failure` because those states carry no
summary; only `empty` and `success` do.

### Detail sheet — `/sarpras/:id`

Opened with the id from the tapped item. `DetailSarprasCubit` fetches on
open rather than reusing the list item, so the sheet reflects any status
change that happened since the list was loaded.

Content: all activity fields, then a resolution block when the request has
been processed — resolver name, resolved-at timestamp, and the rejection
reason. When the status is Ditolak the rejection reason is the most
prominent element on the sheet; it is the reason the user opened it.

Actions, rendered only when `sarpras.isCancelable`:

- `AppButton.outlined` — Edit, pushes `/sarpras/:id/edit`
- `AppButton.text` — Batalkan, opens a confirmation dialog first

### Form sheet — `/sarpras/new` and `/sarpras/:id/edit`

One file. Create and edit differ only in initial values and which cubit
receives the submit.

Edit mode gets its initial values from its own `DetailSarprasCubit`
instance, fetched by id — not from data handed over by the detail sheet. The
edit route is reachable directly by deep link, so it cannot assume the detail
sheet was opened first. While that fetch is in flight the form shows a
shimmer; if it fails, the sheet shows a failure state with retry instead of
an empty form.

If the fetched request is not `isCancelable`, the edit sheet does not render
the form at all. It shows a short "sudah diproses" state with a close action.
This is the deep-link guard: the rule is enforced where the data arrives, not
only where the Edit button is drawn.

| Field | Control | Rule |
| --- | --- | --- |
| Tanggal kegiatan | `showDatePicker` | Required, not in the past |
| Nama kegiatan | `AppTextField` | Required, max 150 |
| Jumlah siswa | `AppTextField`, numeric keyboard | Required, sent as String |
| Guru pembimbing | Dropdown | Required, NIP from candidate list |
| Jam mulai | `showTimePicker` | Required |
| Jam selesai | `showTimePicker` | Required, strictly after jam mulai |
| Keterangan | `AppTextField` multiline | Optional, max 500 |

Length limits mirror the API schema so input is rejected client-side rather
than returning a 422.

`jumlah_siswa_kelas` is a String in the API. The field uses a numeric
keyboard for usability but the value is passed through as text — no int
parsing, no reformatting.

The teacher dropdown has its own loading, failure-with-retry, and empty
states. While the candidate list is unavailable the submit button stays
disabled: without a valid NIP the request cannot succeed.

Submit is disabled while the write cubit is in `loading`, preventing double
submission. On success the sheet pops and an `AppToast` confirms. On failure
the sheet stays open, keeping the user's input, and shows the failure via
`AppToast`.

## Domain change

`Sarpras.isCancelable` — a getter returning `status == 'Menunggu'`.

The rule lives in the entity, not in widget `if` statements, because both
the detail sheet and the edit route guard depend on it. The backend's 422
("Permohonan sudah diproses dan tidak bisa dibatalkan") is the second line
of defence, not the first.

Status strings are compared against the literal `'Menunggu'` returned by the
API, matching how `SarprasSummaryModel` already maps the `ringkasan` keys.

## Localization

Roughly 30 new keys in both `app_en.arb` and `app_id.arb`, covering screen
titles, the four chip labels, field labels and validation messages, empty
and failure states, action labels, and toast messages.

All visible text goes through `AppLocalizations.of(context)!`.

## Testing

Unit:

- `Sarpras.isCancelable` is true only for `Menunggu`

Widget:

- List renders loading, empty, populated, and failure states
- Filter chips actually narrow the rendered list
- Edit and Batalkan are absent when status is Disetujui or Ditolak
- Form rejects jam selesai equal to or earlier than jam mulai
- Form rejects a past tanggal kegiatan
- Submit is disabled while the teacher candidate list is unavailable
- Edit sheet shows the "sudah diproses" state instead of a form when the
  fetched request is not cancelable

Form validation is covered by widget tests rather than manual checking. This
is the app's first write path; a bad submission puts junk data into the
school's system.

## Entry point

A `MenuSheetItem` with `Icons.meeting_room_rounded` and label
`izinSarpras`, added to `MenuSheetItem.menuItems` alongside the existing
seven, plus a matching branch in `resolveLabel`. The quick-menu section on
the student dashboard picks it up automatically; it filters only
`RouteNames.settings` out.

Parent shells do not render this menu, which is what keeps the feature
student-only.

## Risks

**Cupertino sheet on an Android-first app.** `CupertinoSheetRoute` is an
iOS-styled presentation and MyBL ships primarily to Play Store. The stacked
-card effect itself is visually neutral, but it is a deliberate style choice,
not the Material default.

**Date picker and sheet drag gestures.** A `showDatePicker` inside a
draggable sheet can compete for vertical drag. If this shows up during
implementation, set `enableDrag: false` on the form sheet and rely on an
explicit close button.
