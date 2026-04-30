// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  /// Definisi Tema Terang (Light Mode).
  ///
  /// Menggunakan [_baseColor] sebagai warna dasar (seed color) dan
  /// font Poppins untuk keseluruhan teks.
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _baseColor,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
  );

  /// Definisi Tema Gelap (Dark Mode).
  ///
  /// Memiliki konfigurasi yang sama dengan [lightTheme] namun dengan
  /// kecerahan (brightness) yang diatur ke gelap.
  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _baseColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
  );
}
