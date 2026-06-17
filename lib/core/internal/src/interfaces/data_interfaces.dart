// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../types.dart';

abstract interface class ItemFetcher<T> {
  Future<Result<T>> fetch([bool forceRefresh = false]);
}

abstract interface class ListFetcher<T> {
  Future<Result<List<T>>> fetchAll([bool forceRefresh = false]);
}

abstract interface class CacheStorage<T> {
  Future<Unit> save(T data);

  T? read();
}

abstract interface class ListCacheStorage<T> {
  Future<Unit> save(List<T> listData);

  List<T>? read();
}

abstract interface class HTTPRequest {
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  });

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? queryParameters,
    required Map<String, dynamic> data,
  });

  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? queryParameters,
    required Map<String, dynamic> data,
  });

  Future<Unit> delete(String url, {Map<String, dynamic>? data});
}

abstract interface class Authenticator<T> {
  Future<Result<T>> login({required String nis, required String password});

  Future<Result<Unit>> logout();
}

abstract interface class RememberMeStorage {
  Future<String?> readNIS();

  Future<Unit> saveNIS(String nis);
}

abstract interface class TokenStorage {
  Future<String?> readAccessToken();

  Future<Unit> saveAccessToken(String accessToken);

  Future<Unit> clearAccessToken();

  Future<Unit> saveTokenExpiresAt(DateTime expiresAt);

  Future<DateTime?> readTokenExpiresAt();

  Future<Unit> clearTokenExpiresAt();
}

abstract interface class ParentTokenStorage {
  Future<String?> readParentAccessToken();

  Future<Unit> saveParentAccessToken(String accessToken);

  Future<Unit> clearParentAccessToken();

  Future<DateTime?> readParentTokenExpiresAt();

  Future<Unit> saveParentTokenExpiresAt(DateTime expiresAt);

  Future<Unit> clearParentTokenExpiresAt();
}

abstract interface class RoleStorage<T> {
  Future<Unit> saveRole(T role);

  Future<T?> readRole();

  Future<Unit> clearRole();
}

abstract interface class LocalStorageManager {
  Future<void> openAllBoxes();

  Future<void> clearAllBoxes();

  Future<void> closeAllBoxes();
}

abstract interface class AttendanceFetcher<T> {
  Future<Result<T?>> fetchDailyAttendance([bool forceRefresh = false]);

  Future<Result<List<T>>> fetchMonthlyAttendance({
    required int month,
    required int year,
    bool forceRefresh = false,
  });
}

abstract interface class AttendanceLocalManager<T> {
  Future<Unit> saveMonthlyAttendance({
    required int month,
    required int year,
    required List<T> listData,
  });

  Future<Unit> saveDailyAttendance(T data);

  List<T>? readMonthlyAttendance({required int month, required int year});

  T? readDailyAttendance();
}

abstract interface class TimeTableLocalManager<T> {
  Future<Unit> saveListTimeTable({required List<T> listData});

  List<T>? readListTimeTable();
}

abstract interface class MeritDemeritFetcher<M, D> {
  Future<Result<List<M>?>> fetchMerit({
    String? schoolSession,
    String? semester,
    bool forceRefresh = false,
  });

  Future<Result<List<D>?>> fetchDemerit({
    String? schoolSession,
    String? semester,
    bool forceRefresh = false,
  });
}

abstract interface class MeritDemeritLocalManager<M, D> {
  Future<Unit> saveListMerit(List<M> listData);

  Future<Unit> saveListDemerit(List<D> listData);

  List<M>? readListMerit();

  List<D>? readListDemerit();
}

abstract interface class AcademicCalendarFetcher<T> {
  Future<Result<List<T>?>> fetchAcademicCalendar({
    required int year,
    required int month,
    required String unit,
    bool forceRefresh = false,
  });
}

abstract interface class AcademicCalendarLocalManager<T> {
  Future<Unit> saveMonthlyAcademicCalendar({
    required int month,
    required int year,
    required List<T> listData,
  });

  List<T>? readMonthlyAcademicCalendar({required int month, required int year});
}

abstract interface class NotificationLocalManager<T> {
  Future<Unit> saveNotification(T data);

  List<T> readNotifications();

  Future<Unit> markAsRead(int id);

  Future<Unit> clearNotifications();
}

abstract interface class DeviceTokenRegistrar {
  Future<Result<Unit>> registerDeviceToken({required String fcmToken});

  Future<Result<Unit>> revokeDeviceToken({required String fcmToken});
}
