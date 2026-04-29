import 'package:flutter/material.dart';
import 'package:my_bl/core/theme/theme.dart';

class MyBLApp extends StatelessWidget {
  const MyBLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: BLTheme.lightTheme, darkTheme: BLTheme.darkTheme);
  }
}
