// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/dashboard/presentation/widgets/parent_profile_children_section.dart';
import 'package:my_bl/features/user/domain/entities/child_entity/child_entity.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/l10n/app_localizations_en.dart';

final AppLocalizationsEn _l10n = AppLocalizationsEn();

const _budi = ChildEntity(nis: '111', nama: 'Budi', kelas: 'XI A');
const _sari = ChildEntity(nis: '222', nama: 'Sari', kelas: 'X B');

Widget _wrap({
  required List<ChildEntity> children,
  required ChildEntity? selectedChild,
  required void Function(ChildEntity) onChildSelected,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: CustomScrollView(
        slivers: [
          ParentProfileChildrenSection(
            children: children,
            selectedChild: selectedChild,
            onChildSelected: onChildSelected,
          ),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('tapping the already-active child shows no dialog and does '
      'not call onChildSelected', (tester) async {
    var called = false;

    await tester.pumpWidget(
      _wrap(
        children: const [_budi, _sari],
        selectedChild: _budi,
        onChildSelected: (_) => called = true,
      ),
    );

    await tester.tap(find.text('Budi'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(called, isFalse);
  });

  testWidgets('tapping a different child shows a confirm dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        children: const [_budi, _sari],
        selectedChild: _budi,
        onChildSelected: (_) {},
      ),
    );

    await tester.tap(find.text('Sari'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(_l10n.parentProfileSwitchChildTitle), findsOneWidget);
    expect(
      find.text(_l10n.parentProfileSwitchChildMessage('Sari')),
      findsOneWidget,
    );
  });

  testWidgets('confirming the dialog calls onChildSelected with the child', (
    tester,
  ) async {
    ChildEntity? selected;

    await tester.pumpWidget(
      _wrap(
        children: const [_budi, _sari],
        selectedChild: _budi,
        onChildSelected: (child) => selected = child,
      ),
    );

    await tester.tap(find.text('Sari'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_l10n.confirm));
    await tester.pumpAndSettle();

    expect(selected, _sari);
  });
}
