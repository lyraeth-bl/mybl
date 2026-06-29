import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/features/dashboard/presentation/screens/parent_profile_screen.dart';

void main() {
  testWidgets('ParentProfileScreen renders a Scaffold', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: ParentProfileScreen(),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
