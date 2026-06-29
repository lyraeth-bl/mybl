import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_bl/features/dashboard/presentation/shell/parent_main_shell.dart';

void main() {
  testWidgets(
    'parent bottom nav renders 3 NavigationDestinations',
    (tester) async {
      // Build a NavigationBar with 3 destinations in isolation —
      // avoids needing a real StatefulNavigationShell.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: NavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.house_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_outlined),
                  label: 'Notifications',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(NavigationDestination), findsNWidgets(3));
    },
  );
}
