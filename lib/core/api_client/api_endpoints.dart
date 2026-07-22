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

class ApiEndpoints {
  static String get baseUrl => _databaseUrl;

  // --- SPO --- //
  static final String login = "/login";

  static final String loginParent = "/auth/login/parent";

  static final String logout = "/logout";

  static final String logoutParent = "/parent/logout";

  static final String me = "/me";

  static final String parentMe = "/parent/me";

  static final String attendance = "/absensi-harian";

  static final String todayAttendance = "/absensi-harian/today";

  static final String attendanceQrToken = "/absensi/qr-token";

  static final String deviceTokens = "/device-tokens";

  static final String parentDeviceTokens = "/parent/device-tokens";

  static final String academicCalendar = "/kalender-akademik";

  static final String feedback = "/feedback";

  static final String appConfig = "/app-config";

  static final String parentAppConfig = "/parent/app-config";

  static final String merit = "/merit";

  static final String demerit = "/demerit";

  static final String extracurricular = "/ekskul";

  static final String result = "/nilai";

  static final String parentAttendance = "/parent/absensi-harian";

  static final String parentTodayAttendance = "/parent/absensi-today";

  static final String listSarpras = "/izin-sarpras";

  static final String sarprasGuruPendamping = "/izin-sarpras/guru-pembimbing";

  static String sarpras(int sarprasId) => "/izin-sarpras/$sarprasId";

  // --- Internal --- //

  static final String timeTable = "$_databaseInternalUrl/jadwal";
}
