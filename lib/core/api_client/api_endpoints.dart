// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

part of 'api_client.dart';

final String _envErrorMessage =
    "Ada yang lupa setup .env nih, setup dulu ya dengan copy .env.example";

final String _baseSanctum =
    dotenv.env['BASE_URL'] ?? (throw Exception(_envErrorMessage));

final String _baseInternal =
    dotenv.env['BASE_URL_INTERNAL'] ?? (throw Exception(_envErrorMessage));

final String _databaseUrl = "$_baseSanctum/api";

final String _databaseInternalUrl = "$_baseInternal/api";

class ApiEndpoints {
  /// Getter baseUrl khusus untuk oleh [initNetworkDI] untuk
  /// inisialisasi baseUrl pada Dio.
  ///
  /// Jadi pada remote data source cukup :
  ///
  /// ```dart
  /// final response = await _apiClient.get(ApiEndpoints.login);
  /// ```
  ///
  /// Selain dari penggunaan di [initNetworkDI], getter ini tidak berguna.
  static String get baseUrl => _databaseUrl;

  // --- SPO --- //
  static final String login = "/login";

  static final String logout = "/logout";

  static final String me = "/me";

  static final String attendance = "/absensi-harian";

  static final String deviceTokens = "/device-tokens";

  static final String academicCalendar = "/kalender-akademik";

  static final String feedback = "/feedback";

  static final String appConfig = "/app-config";

  static final String merit = "/merit";

  static final String demerit = "/demerit";

  static final String extracurricular = "/ekskul";

  static final String result = "/nilai";

  // --- Internal --- //

  /// Khusus untuk url [timeTable], dikarenakan api ini mengambil data dari
  /// api internal, jadi format isinya sedikit berbeda dari api SPO.
  ///
  /// Dan ini sebenernya tidak apa apa di Dio, karena [_databaseInternalUrl]
  /// merupakan full path URL, Dio otomatis akan mengoverride [baseUrl]
  /// sebelumnya.
  ///
  /// Jadi url Dio tidak ada seperti ini:
  /// ```dart
  /// https://baseurl.com/apihttps://internalurl.com/api/jadwal
  /// ```
  ///
  /// Tapi, akan di override seperti ini:
  ///
  /// ```dart
  /// https://internalurl.com/api/jadwal
  /// ```
  ///
  /// Contoh:
  /// ```dart
  /// final response = await _apiClient.get(ApiEndpoints.timeTable);
  /// ```
  static final String timeTable = "$_databaseInternalUrl/jadwal";
}
