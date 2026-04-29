// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

/// Penyimpanan lokal menggunakan [FlutterSecureStorage].
///
/// Digunakan khusus untuk data sensitif seperti token autentikasi.
/// Data di sini dienkripsi oleh OS (Keychain di iOS, Keystore di Android),
/// sehingga lebih aman dibanding Hive yang disimpan plain di disk.
///
/// Untuk data non-sensitif, gunakan [HiveStorageNames].
class SecureStorageNames {
  static const String accessTokenKey = "auth-kAccessToken";
}
