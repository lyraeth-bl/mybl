// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/core/di/get_it_constant.dart';
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
  when(bloc.close).thenAnswer((_) async {});
  return bloc;
}

Widget _wrap(SarprasBloc bloc) {
  di.registerFactory<SarprasBloc>(() => bloc);

  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: const SarprasScreen(),
  );
}

void main() {
  tearDown(() => di.reset());

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
      _wrap(_bloc(const SarprasState.failure(Failure.unexpected()))),
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
