// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/core/di/get_it_constant.dart';
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
  when(
    () => detail.state,
  ).thenReturn(DetailSarprasState.success(sarpras: sarpras));
  when(() => detail.stream).thenAnswer((_) => const Stream.empty());
  when(() => detail.fetchDetail(sarprasId: 4)).thenAnswer((_) async {});
  when(detail.close).thenAnswer((_) async {});

  final destroy = _MockDestroyCubit();
  when(() => destroy.state).thenReturn(const DestroySarprasState.initial());
  when(() => destroy.stream).thenAnswer((_) => const Stream.empty());
  when(destroy.close).thenAnswer((_) async {});

  di.registerFactory<DetailSarprasCubit>(() => detail);
  di.registerFactory<DestroySarprasCubit>(() => destroy);

  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: const SarprasDetailSheet(sarprasId: 4),
  );
}

void main() {
  tearDown(() => di.reset());

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

  testWidgets('renders waktuKegiatan verbatim without parsing it', (
    tester,
  ) async {
    final sarpras = _sarpras(
      status: 'Menunggu',
    ).copyWith(waktuKegiatan: 'Sepanjang hari');
    await tester.pumpWidget(_wrap(sarpras));
    await tester.pumpAndSettle();

    expect(find.text('Sepanjang hari'), findsOneWidget);
    expect(find.text(_l10n.sarprasFieldTime), findsOneWidget);
    expect(find.text(_l10n.sarprasFieldStartTime), findsNothing);
    expect(find.text(_l10n.sarprasFieldEndTime), findsNothing);
  });
}
