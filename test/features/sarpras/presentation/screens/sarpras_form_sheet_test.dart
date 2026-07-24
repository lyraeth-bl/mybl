// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/core/di/get_it_constant.dart';
import 'package:my_bl/core/widgets/app_button.dart';
import 'package:my_bl/core/widgets/app_text_field.dart';
import 'package:my_bl/features/sarpras/data/models/sarpras_request/sarpras_request.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras/sarpras.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras_params/sarpras_params.dart';
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

final Sarpras _cancelable = Sarpras(
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

Widget _wrap({
  required SarprasTeacherCandidateState candidateState,
  DetailSarprasState? detailState,
  int? sarprasId,
  StoreSarprasState? storeState,
  void Function(_MockStoreCubit store)? onStore,
  void Function(_MockUpdateCubit update)? onUpdate,
}) {
  final candidates = _MockCandidateCubit();
  when(() => candidates.state).thenReturn(candidateState);
  when(() => candidates.stream).thenAnswer((_) => const Stream.empty());
  when(() => candidates.fetchCandidates()).thenAnswer((_) async {});
  when(candidates.close).thenAnswer((_) async {});

  final store = _MockStoreCubit();
  when(
    () => store.state,
  ).thenReturn(storeState ?? const StoreSarprasState.initial());
  when(() => store.stream).thenAnswer((_) => const Stream.empty());
  when(store.close).thenAnswer((_) async {});
  onStore?.call(store);

  final update = _MockUpdateCubit();
  when(() => update.state).thenReturn(const UpdateSarprasState.initial());
  when(() => update.stream).thenAnswer((_) => const Stream.empty());
  when(update.close).thenAnswer((_) async {});
  onUpdate?.call(update);

  final detail = _MockDetailCubit();
  final resolvedDetailState = detailState ?? const DetailSarprasState.initial();
  when(() => detail.state).thenReturn(resolvedDetailState);
  when(
    () => detail.stream,
  ).thenAnswer((_) => Stream.value(resolvedDetailState));
  when(() => detail.fetchDetail(sarprasId: 4)).thenAnswer((_) async {});
  when(detail.close).thenAnswer((_) async {});

  di.registerFactory<SarprasTeacherCandidateCubit>(() => candidates);
  di.registerFactory<StoreSarprasCubit>(() => store);
  di.registerFactory<UpdateSarprasCubit>(() => update);
  di.registerFactory<DetailSarprasCubit>(() => detail);

  return MaterialApp(
    // Forces 24-hour entry so tests can type e.g. "15" as an hour without
    // fighting the AM/PM segmented control of the 12-hour input mode.
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: SarprasFormSheet(sarprasId: sarprasId),
  );
}

/// Opens the time picker behind [openField], switches it to keyboard input,
/// types [hour]:[minute], and confirms.
Future<void> _setTime(
  WidgetTester tester, {
  required Finder openField,
  required String hour,
  required String minute,
}) async {
  // Tap the InkWell tap target itself rather than the internal label text,
  // whose painted position (floating vs centered) shifts with field state.
  final inkWell = find.ancestor(of: openField, matching: find.byType(InkWell));
  await tester.tap(inkWell.first);
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.keyboard_outlined));
  await tester.pumpAndSettle();

  final timeFields = find.descendant(
    of: find.byType(Dialog),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(timeFields.at(0), hour);
  await tester.enterText(timeFields.at(1), minute);
  await tester.pumpAndSettle();

  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      SarprasParams(
        tanggalKegiatan: DateTime(2026),
        namaKegiatan: 'fallback',
        jumlahSiswaDalamKegiatan: '1',
        nipGuruPembimbing: '20250602',
        jamMulaiKegiatan: DateTime(2026, 1, 1, 8),
        jamSelesaiKegiatan: DateTime(2026, 1, 1, 9),
      ),
    );
  });

  tearDown(() => di.reset());

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

  testWidgets(
    'shows required-field errors and blocks submit when date/time unset',
    (tester) async {
      late _MockStoreCubit storeCubit;

      await tester.pumpWidget(
        _wrap(
          candidateState: const SarprasTeacherCandidateState.success(
            candidates: [_teacher],
          ),
          onStore: (cubit) => storeCubit = cubit,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(AppTextField).at(0), 'Rapat OSIS');
      await tester.enterText(find.byType(AppTextField).at(1), '10');

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_teacher.name).last);
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(
        AppButton,
        _l10n.sarprasSaveAction,
      );
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.text(_l10n.sarprasValidationRequired), findsNWidgets(3));
      verifyNever(() => storeCubit.storeSarpras(any()));
    },
  );

  testWidgets(
    'shows required-field errors instead of doing nothing when editing '
    'without re-picking times',
    (tester) async {
      late _MockUpdateCubit updateCubit;

      await tester.pumpWidget(
        _wrap(
          candidateState: const SarprasTeacherCandidateState.success(
            candidates: [_teacher],
          ),
          detailState: DetailSarprasState.success(sarpras: _cancelable),
          sarprasId: 4,
          onUpdate: (cubit) => updateCubit = cubit,
        ),
      );
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(
        AppButton,
        _l10n.sarprasSaveAction,
      );
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.text(_l10n.sarprasValidationRequired), findsNWidgets(2));
      verifyNever(
        () => updateCubit.updateSarpras(
          sarprasId: any(named: 'sarprasId'),
          params: any(named: 'params'),
        ),
      );
    },
  );

  testWidgets('disables submit while a store request is in flight', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        candidateState: const SarprasTeacherCandidateState.success(
          candidates: [_teacher],
        ),
        storeState: const StoreSarprasState.loading(),
      ),
    );
    await tester.pump();

    final button = tester.widget<AppButton>(find.byType(AppButton).last);
    expect(button.onPressed, isNull);
  });

  testWidgets(
    'normalizes a UTC-parsed prefill date so the update request carries '
    'the local calendar day with no timezone marker',
    (tester) async {
      late _MockUpdateCubit updateCubit;

      // Mirrors the backend's real shape: a UTC instant representing a
      // local midnight, well clear of "today" in either direction so the
      // past-date rule never interferes with this test.
      final utcActivityDate = DateTime.now().toUtc().add(
        const Duration(days: 3),
      );
      final expectedLocalDate = DateUtils.dateOnly(utcActivityDate.toLocal());
      final sarpras = _cancelable.copyWith(tanggalKegiatan: utcActivityDate);

      await tester.pumpWidget(
        _wrap(
          candidateState: const SarprasTeacherCandidateState.success(
            candidates: [_teacher],
          ),
          detailState: DetailSarprasState.success(sarpras: sarpras),
          sarprasId: 4,
          onUpdate: (cubit) {
            updateCubit = cubit;
            when(
              () => cubit.updateSarpras(
                sarprasId: any(named: 'sarprasId'),
                params: any(named: 'params'),
              ),
            ).thenAnswer((_) async {});
          },
        ),
      );
      await tester.pumpAndSettle();

      await _setTime(
        tester,
        openField: find.text(_l10n.sarprasFieldStartTime),
        hour: '12',
        minute: '00',
      );
      await _setTime(
        tester,
        openField: find.text(_l10n.sarprasFieldEndTime),
        hour: '15',
        minute: '00',
      );

      final saveButton = find.widgetWithText(
        AppButton,
        _l10n.sarprasSaveAction,
      );
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      final captured = verify(
        () => updateCubit.updateSarpras(
          sarprasId: any(named: 'sarprasId'),
          params: captureAny(named: 'params'),
        ),
      ).captured;

      final request = (captured.single as SarprasParams).toRequest().toJson();
      final expectedPrefix =
          '${expectedLocalDate.year}-'
          '${expectedLocalDate.month.toString().padLeft(2, '0')}-'
          '${expectedLocalDate.day.toString().padLeft(2, '0')}';

      expect(request['tanggal_kegiatan'], isNot(endsWith('Z')));
      expect(request['tanggal_kegiatan'], startsWith(expectedPrefix));
    },
  );

  testWidgets('blocks submit with a past-date error when editing an unchanged '
      'past activity date', (tester) async {
    late _MockUpdateCubit updateCubit;
    final pastActivity = _cancelable.copyWith(
      tanggalKegiatan: DateTime.now().subtract(const Duration(days: 1)),
    );

    await tester.pumpWidget(
      _wrap(
        candidateState: const SarprasTeacherCandidateState.success(
          candidates: [_teacher],
        ),
        detailState: DetailSarprasState.success(sarpras: pastActivity),
        sarprasId: 4,
        onUpdate: (cubit) => updateCubit = cubit,
      ),
    );
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(AppButton, _l10n.sarprasSaveAction);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text(_l10n.sarprasValidationPastDate), findsOneWidget);
    verifyNever(
      () => updateCubit.updateSarpras(
        sarprasId: any(named: 'sarprasId'),
        params: any(named: 'params'),
      ),
    );
  });

  testWidgets(
    'clears a stale supervising teacher instead of crashing the dropdown',
    (tester) async {
      late _MockUpdateCubit updateCubit;
      final staleTeacherSarpras = _cancelable.copyWith(
        nipGuruPembimbing: 'DEPARTED_NIP',
      );

      await tester.pumpWidget(
        _wrap(
          candidateState: const SarprasTeacherCandidateState.success(
            candidates: [_teacher],
          ),
          detailState: DetailSarprasState.success(sarpras: staleTeacherSarpras),
          sarprasId: 4,
          onUpdate: (cubit) => updateCubit = cubit,
        ),
      );
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(
        AppButton,
        _l10n.sarprasSaveAction,
      );
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      // Teacher, start time, and end time all report as required: the
      // stale NIP was cleared rather than left dangling behind a blank
      // dropdown, and no debug assertion fired while rendering it.
      expect(find.text(_l10n.sarprasValidationRequired), findsNWidgets(3));
      verifyNever(
        () => updateCubit.updateSarpras(
          sarprasId: any(named: 'sarprasId'),
          params: any(named: 'params'),
        ),
      );
    },
  );
}
