// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    this.success = const Color(0xFF2E7D32),
    this.warning = const Color(0xFFF9A825),
  });

  final Color success;

  final Color warning;

  @Deprecated(
    'Use success instead. This alias will be removed in a future release.',
  )
  Color get greenColor => success;

  @Deprecated(
    'Use warning instead. This alias will be removed in a future release.',
  )
  Color get yellowColor => warning;

  static AppColors? maybeOf(BuildContext context) {
    return Theme.of(context).extension<AppColors>();
  }

  static AppColors of(BuildContext context) {
    final AppColors? colors = maybeOf(context);
    if (colors != null) {
      return colors;
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AppColors(success: colorScheme.tertiary, warning: colorScheme.error);
  }

  @override
  AppColors copyWith({
    Color? success,
    Color? warning,
    @Deprecated(
      'Use success instead. This parameter will be removed in a future release.',
    )
    Color? greenColor,
    @Deprecated(
      'Use warning instead. This parameter will be removed in a future release.',
    )
    Color? yellowColor,
  }) {
    assert(
      success == null || greenColor == null,
      'Only one of success or greenColor can be provided.',
    );
    assert(
      warning == null || yellowColor == null,
      'Only one of warning or yellowColor can be provided.',
    );

    return AppColors(
      success: success ?? greenColor ?? this.success,
      warning: warning ?? yellowColor ?? this.warning,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

class MyBlTheme {
  static final Color _baseColor = Color.fromARGB(255, 32, 161, 219);

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _baseColor,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(fontWeight: .w700),
      displayMedium: GoogleFonts.plusJakartaSans(fontWeight: .w700),
      displaySmall: GoogleFonts.plusJakartaSans(fontWeight: .w700),
      headlineLarge: GoogleFonts.plusJakartaSans(fontWeight: .w600),
      headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: .w600),
      headlineSmall: GoogleFonts.plusJakartaSans(fontWeight: .w600),
      titleLarge: GoogleFonts.plusJakartaSans(fontWeight: .w600),
      titleMedium: GoogleFonts.plusJakartaSans(fontWeight: .w600),
      titleSmall: GoogleFonts.plusJakartaSans(fontWeight: .w600),
    ),
    useMaterial3: true,
    extensions: const <ThemeExtension<dynamic>>[
      AppColors(success: Colors.green, warning: Colors.yellow),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _baseColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(fontWeight: .w700),
      displayMedium: GoogleFonts.plusJakartaSans(fontWeight: .w700),
      displaySmall: GoogleFonts.plusJakartaSans(fontWeight: .w700),
      headlineLarge: GoogleFonts.plusJakartaSans(fontWeight: .w600),
      headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: .w600),
      headlineSmall: GoogleFonts.plusJakartaSans(fontWeight: .w600),
      titleLarge: GoogleFonts.plusJakartaSans(fontWeight: .w600),
      titleMedium: GoogleFonts.plusJakartaSans(fontWeight: .w600),
      titleSmall: GoogleFonts.plusJakartaSans(fontWeight: .w600),
    ),
    useMaterial3: true,
    extensions: const <ThemeExtension<dynamic>>[
      AppColors(success: Colors.greenAccent, warning: Colors.yellowAccent),
    ],
  );
}
