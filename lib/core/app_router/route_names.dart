// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

part of 'app_router.dart';

class RouteNames {
  RouteNames._();

  // Splash Route
  static const String splash = "/";

  // Welcome Screen
  static const String welcome = "/welcome";

  // Auth Student Screen
  static const String authStudent = "/auth/student";

  // Auth Parent Screen
  static const String authParent = "/auth/parent";

  // Forgot Password — NIS input
  static const String forgotPassword = "/forgot-password";

  // Forgot Password — OTP input
  static const String forgotPasswordOtp = "/forgot-password/otp";

  // Forgot Password — new password input
  static const String forgotPasswordReset = "/forgot-password/reset";

  // Parent Child Selector
  static const String parentChildSelector = "/parent/select-child";

  // Dashboard
  static const String dashboard = "/dashboard";

  // Parent Dashboard
  static const String parentDashboard = "/parent/dashboard";

  // Parent Notification
  static const String parentNotification = "/parent/notification";

  // Parent Profile
  static const String parentProfile = "/parent/profile";

  // Attendance
  static const String attendance = "/attendance";

  // Profile
  static const String profile = "/profile";

  // Profile
  static const String profileDetail = "/profileDetail";

  // TimeTable
  static const String timeTable = "/timeTable";

  // Guardians details
  static const String guardianDetails = "/guardianDetails";

  // Extracurricular
  static const String extracurricular = "/extracurricular";

  // Extracurricular attendance detail
  static const String extracurricularAttendanceDetail =
      "/extracurricular/attendance/:id";

  // Merit and Demerit.
  static const String meritAndDemerit = "/meritAndDemerit";

  // Academic Calendar
  static const String academicCalendar = "/academicCalendar";

  // Academic Result
  static const String academicResult = "/academicResult";

  // Notifications
  static const String notification = "/notification";

  // Settings
  static const String settings = "/settings";

  // Help Center
  static const String helpCenter = "/settings/help-center";

  // Privacy Policy
  static const String privacyPolicy = "/settings/privacy-policy";

  // Sarpras
  static const String sarpras = "/sarpras";

  // Sarpras New Request
  static const String sarprasNew = "/sarpras/new";

  // Sarpras Detail
  static const String sarprasDetail = "/sarpras/:id";

  // Sarpras Edit
  static const String sarprasEdit = "/sarpras/:id/edit";
}
