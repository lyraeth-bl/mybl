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
  /// --- SPO --- ///
  static final String login = "$_databaseUrl/login";

  static final String logout = "$_databaseUrl/logout";

  static final String me = "$_databaseUrl/me";

  static final String attendance = "$_databaseUrl/absensi-harian";

  static final String deviceTokens = "$_databaseUrl/device-tokens";

  static final String academicCalendar = "$_databaseUrl/kalender-akademik";

  static final String feedback = "$_databaseUrl/feedback";

  static final String appConfig = "$_databaseUrl/app-config";

  static final String merit = "$_databaseUrl/merit";

  static final String demerit = "$_databaseUrl/demerit";

  static final String extracurricular = "$_databaseUrl/ekskul";

  static final String result = "$_databaseUrl/nilai";

  /// --- Internal --- ///
  static final String timeTable = "$_databaseInternalUrl/jadwal";
}
