// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Additional semantic colors used by the application.
///
/// Add [AppColors] to [ThemeData.extensions] when the UI needs semantic colors
/// that are not represented directly by [ColorScheme].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Creates a set of application semantic colors.
  const AppColors({
    this.success = const Color(0xFF2E7D32),
    this.warning = const Color(0xFFF9A825),
  });

  /// The color used for successful or positive states.
  final Color success;

  /// The color used for warning or caution states.
  final Color warning;

  /// Deprecated alias for [success].
  @Deprecated(
    'Use success instead. This alias will be removed in a future release.',
  )
  Color get greenColor => success;

  /// Deprecated alias for [warning].
  @Deprecated(
    'Use warning instead. This alias will be removed in a future release.',
  )
  Color get yellowColor => warning;

  /// Returns the closest [AppColors] extension from [ThemeData], if one exists.
  static AppColors? maybeOf(BuildContext context) {
    return Theme.of(context).extension<AppColors>();
  }

  /// Returns the closest [AppColors] extension from [ThemeData].
  ///
  /// If no extension is registered, values are derived from the current
  /// [ColorScheme].
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

/// Konfigurasi tema untuk aplikasi Budi Luhur.
///
/// Ubah pengaturan seperti font, skema warna, dan tema widget lainnya di sini.
class MyBlTheme {
  /// Warna dasar (warna Biru) Budi Luhur.
  ///
  /// Nomor .fromARGB di sini didapat dari hasil ekstrak warna biru pada logo
  /// Budi Luhur.
  ///
  /// Format warna lain:
  /// - `#20A1DB` untuk versi HEX.
  static final Color _baseColor = Color.fromARGB(255, 32, 161, 219);

  /// Typography: Nunito (display/headlines) + Plus Jakarta Sans (body/labels).
  ///
  /// Weights in use: w400 · w500 · w600 · w700 — max 4 per mobile-ui-ux rules.
  static TextTheme _buildTextTheme() {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      // --- Headlines: Nunito ---
      headlineLarge: GoogleFonts.nunito(
        textStyle: base.headlineLarge,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.nunito(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: GoogleFonts.nunito(
        textStyle: base.headlineSmall,
        fontWeight: FontWeight.w600,
      ),
      // --- Titles: Plus Jakarta Sans ---
      titleLarge: GoogleFonts.plusJakartaSans(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        textStyle: base.titleMedium,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        textStyle: base.titleSmall,
        fontWeight: FontWeight.w500,
      ),
      // --- Body: Plus Jakarta Sans ---
      bodyLarge: GoogleFonts.plusJakartaSans(
        textStyle: base.bodyLarge,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        textStyle: base.bodyMedium,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        textStyle: base.bodySmall,
        fontWeight: FontWeight.w400,
      ),
      // --- Labels: Plus Jakarta Sans ---
      labelLarge: GoogleFonts.plusJakartaSans(
        textStyle: base.labelLarge,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        textStyle: base.labelMedium,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        textStyle: base.labelSmall,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static final TextTheme _textTheme = _buildTextTheme();

  /// Definisi Tema Terang (Light Mode).
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _baseColor,
      brightness: Brightness.light,
    ),
    textTheme: _textTheme,
    useMaterial3: true,
    extensions: const <ThemeExtension<dynamic>>[
      AppColors(success: Colors.green, warning: Colors.yellow),
    ],
  );

  /// Definisi Tema Gelap (Dark Mode).
  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _baseColor,
      brightness: Brightness.dark,
    ),
    textTheme: _textTheme,
    useMaterial3: true,
    extensions: const <ThemeExtension<dynamic>>[
      AppColors(success: Colors.greenAccent, warning: Colors.yellowAccent),
    ],
  );
}
