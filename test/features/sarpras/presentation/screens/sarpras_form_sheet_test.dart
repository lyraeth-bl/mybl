// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/core/di/get_it_constant.dart';
import 'package:my_bl/core/widgets/app_button.dart';
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
  when(() => candidates.fetchCandidates()).thenAnswer((_) async {});
  when(candidates.close).thenAnswer((_) async {});

  final store = _MockStoreCubit();
  when(() => store.state).thenReturn(const StoreSarprasState.initial());
  when(() => store.stream).thenAnswer((_) => const Stream.empty());
  when(store.close).thenAnswer((_) async {});

  final update = _MockUpdateCubit();
  when(() => update.state).thenReturn(const UpdateSarprasState.initial());
  when(() => update.stream).thenAnswer((_) => const Stream.empty());
  when(update.close).thenAnswer((_) async {});

  final detail = _MockDetailCubit();
  when(
    () => detail.state,
  ).thenReturn(detailState ?? const DetailSarprasState.initial());
  when(() => detail.stream).thenAnswer((_) => const Stream.empty());
  when(() => detail.fetchDetail(sarprasId: 4)).thenAnswer((_) async {});
  when(detail.close).thenAnswer((_) async {});

  di.registerFactory<SarprasTeacherCandidateCubit>(() => candidates);
  di.registerFactory<StoreSarprasCubit>(() => store);
  di.registerFactory<UpdateSarprasCubit>(() => update);
  di.registerFactory<DetailSarprasCubit>(() => detail);

  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: SarprasFormSheet(sarprasId: sarprasId),
  );
}

void main() {
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
}
