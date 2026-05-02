// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

class HiveStorageBoxNames {
  // TODO 1 : Ganti variable name ke appBoxKey.
  // TODO 2 : Hapus [userThemeBoxKey] dan jadikan 1 box untuk Bahasa dan Theme aplikasi.
  // Storage punya `App`
  // Bahasa aplikasi.
  static const String userLocalizationsBoxKey = "userLocalizationsBox";
  static const String userThemeBoxKey = "userThemeBox";

  // Storage spesifik punya `Auth`.
  static const String authBoxKey = "authBox";
}

/// Penyimpanan lokal menggunakan [Hive].
///
/// Digunakan untuk data yang tidak sensitif dan perlu diakses cepat,
/// seperti data profil user yang sudah di-fetch dari server.
///
/// Untuk data sensitif seperti token autentikasi, gunakan [SecureStorageNames].
class HiveStorageNames {
  // TODO : Ganti variable name ke appLocalizationsCodeKey.
  // Bahasa aplikasi.
  static const String userLocalizationsCodeKey = "userLocalizationsCode";

  // TODO : Ganti variable name ke appThemeModeKey.
  // Tema aplikasi.
  static const String userThemeModeKey = "userThemeMode";

  // NIS user jika user mengaktifkan fitur [RememberMe].
  static const String authNISKey = "authNIS";
}
