// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/dashboard/presentation/widgets/parent_profile_overview_section.dart';
import 'package:my_bl/features/user/domain/entities/parent_entity/parent_entity.dart';
import 'package:my_bl/l10n/app_localizations.dart';

Widget _wrap(ParentEntity parent) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: CustomScrollView(
        slivers: [ParentProfileOverviewSection(parent: parent)],
      ),
    ),
  );
}

void main() {
  testWidgets('shows parent name, username, and phone', (tester) async {
    const parent = ParentEntity(
      id: 1,
      nama: 'budi santoso',
      username: 'budi.santoso',
      telpon: '081234567890',
    );

    await tester.pumpWidget(_wrap(parent));

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('budi.santoso'), findsOneWidget);
    expect(find.text('081234567890'), findsOneWidget);
  });
}
