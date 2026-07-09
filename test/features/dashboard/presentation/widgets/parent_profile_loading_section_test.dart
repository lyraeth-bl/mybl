// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/dashboard/presentation/widgets/parent_profile_loading_section.dart';

void main() {
  testWidgets('renders a shimmer placeholder sliver', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomScrollView(slivers: [ParentProfileLoadingSection()]),
        ),
      ),
    );

    expect(find.byType(ParentProfileLoadingSection), findsOneWidget);
    expect(find.byType(SliverToBoxAdapter), findsOneWidget);
  });
}
