// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras_summary/sarpras_summary.dart';
import 'package:my_bl/features/sarpras/presentation/widgets/sarpras_summary_chips.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/l10n/app_localizations_en.dart';

const SarprasSummary _summary = SarprasSummary(
  waiting: 3,
  accepted: 2,
  rejected: 0,
);

FilterChip _chipWithText(WidgetTester tester, String text) =>
    tester.widget<FilterChip>(
      find.ancestor(
        of: find.textContaining(text),
        matching: find.byType(FilterChip),
      ),
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

  testWidgets('disables chips with zero count except All chip', (tester) async {
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
            onSelected: (_) {},
          ),
        ),
      ),
    );

    final l10n = AppLocalizationsEn();

    final allChip = _chipWithText(tester, l10n.sarprasFilterAll);
    final pendingChip = _chipWithText(tester, l10n.sarprasStatusWaiting);
    final approvedChip = _chipWithText(tester, l10n.sarprasStatusAccepted);
    final rejectedChip = _chipWithText(tester, l10n.sarprasStatusRejected);

    expect(allChip.onSelected, isNotNull);
    expect(pendingChip.onSelected, isNotNull);
    expect(approvedChip.onSelected, isNotNull);
    expect(rejectedChip.onSelected, isNull);
  });

  testWidgets('keeps All chip enabled when all status counts are zero', (
    tester,
  ) async {
    const allZeroSummary = SarprasSummary(waiting: 0, accepted: 0, rejected: 0);

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
            summary: allZeroSummary,
            selected: SarprasFilter.all,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    final l10n = AppLocalizationsEn();

    final allChip = _chipWithText(tester, l10n.sarprasFilterAll);
    final pendingChip = _chipWithText(tester, l10n.sarprasStatusWaiting);
    final approvedChip = _chipWithText(tester, l10n.sarprasStatusAccepted);
    final rejectedChip = _chipWithText(tester, l10n.sarprasStatusRejected);

    expect(allChip.onSelected, isNotNull);
    expect(pendingChip.onSelected, isNull);
    expect(approvedChip.onSelected, isNull);
    expect(rejectedChip.onSelected, isNull);
  });
}
