// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

class HiveStorageBoxNames {
  // Storage `App`
  static const String appBoxKey = "appBox";

  // Storage spesifik punya `Auth`.
  static const String authBoxKey = "authBox";

  // Storage spesifik punya `User`.
  static const String userBoxKey = "userBox";
}

/// Penyimpanan lokal menggunakan [Hive].
///
/// Digunakan untuk data yang tidak sensitif dan perlu diakses cepat,
/// seperti data profil user yang sudah di-fetch dari server.
///
/// Untuk data sensitif seperti token autentikasi, gunakan [SecureStorageNames].
class HiveStorageNames {
  // Bahasa aplikasi.
  static const String appLocalizationsCodeKey = "appLocalizationsCode";

  // Tema aplikasi.
  static const String appThemeModeKey = "appThemeMode";

  // Konfigurasi aplikasi.
  static const String appConfigurationKey = "appConfiguration";

  // NIS user jika user mengaktifkan fitur [RememberMe].
  static const String authNISKey = "authNIS";

  // Data student.
  static const String studentDetailKey = "studentDetail";

  // Data absensi bulanan.
  static const String userMonthlyAttendanceKey = "userMonthlyAttendance";

  // Data absensi harian.
  static const String userDailyAttendanceKey = "userDailyAttendance";
}
