// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

class HiveStorageBoxNames {
  static const String userLocalizationsBoxKey = "userLocalizationsBox";
  static const String userThemeBoxKey = "userThemeBox";
}

/// Penyimpanan lokal menggunakan [Hive].
///
/// Digunakan untuk data yang tidak sensitif dan perlu diakses cepat,
/// seperti data profil user yang sudah di-fetch dari server.
///
/// Untuk data sensitif seperti token autentikasi, gunakan [SecureStorageNames].
class HiveStorageNames {
  static const String userLocalizationsCodeKey = "userLocalizationsCode";
  static const String userThemeModeKey = "userThemeMode";
}
