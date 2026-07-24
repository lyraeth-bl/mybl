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
