// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

part of 'api_client.dart';

const String _baseSanctum = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'https://laravel.jh-beon.cloud/api_spo_sanctum/public',
);
const String _baseInternal = String.fromEnvironment(
  'BASE_URL_INTERNAL',
  defaultValue: 'https://sekolahbudiluhur.sch.id/internal/dc_dispo_ok',
);

final String _databaseUrl = "$_baseSanctum/api";

final String _databaseInternalUrl = "$_baseInternal/api";

/// Kumpulan semua endpoint API yang digunakan di aplikasi ini.
///
/// Cara pakainya simpel, tinggal panggil langsung di remote data source:
/// ```dart
/// final response = await _apiClient.get(ApiEndpoints.me);
/// final response = await _apiClient.post(ApiEndpoints.login, data: {...});
/// ```
class ApiEndpoints {
  /// Base URL yang dipakai Dio saat inisialisasi di [initNetworkDI].
  ///
  /// Getter ini **tidak perlu dipanggil langsung** di remote data source.
  /// Cukup pakai endpoint-nya saja (contoh: [login], [me], dst.),
  /// Dio akan otomatis menggabungkan base URL + path endpoint.
  static String get baseUrl => _databaseUrl;

  // --- SPO --- //
  static final String login = "/login";

  static final String logout = "/logout";

  static final String me = "/me";

  static final String attendance = "/absensi-harian";

  static final String todayAttendance = "/absensi-harian/today";

  static final String attendanceQrToken = "/absensi/qr-token";

  static final String deviceTokens = "/device-tokens";

  static final String academicCalendar = "/kalender-akademik";

  static final String feedback = "/feedback";

  static final String appConfig = "/app-config";

  static final String merit = "/merit";

  static final String demerit = "/demerit";

  static final String extracurricular = "/ekskul";

  static final String result = "/nilai";

  // --- Internal --- //

  /// Endpoint ini berbeda dari yang lain karena menggunakan base URL internal
  /// (bukan SPO), sehingga nilainya berupa full URL.
  ///
  /// Tenang saja, Dio sudah handle ini — kalau path-nya full URL,
  /// Dio otomatis mengabaikan [baseUrl] dan langsung hit URL tersebut.
  /// Jadi tidak akan ada double URL seperti ini:
  /// ```
  /// https://spo.com/api/https://internal.com/api/jadwal
  /// ```
  /// Melainkan langsung:
  /// ```
  /// https://internal.com/api/jadwal
  /// ```
  ///
  /// Cara pakainya sama seperti endpoint lain:
  /// ```dart
  /// final response = await _apiClient.get(ApiEndpoints.timeTable);
  /// ```
  static final String timeTable = "$_databaseInternalUrl/jadwal";
}
