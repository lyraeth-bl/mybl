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
