// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../types.dart';

/// Kontrak untuk mengambil satu item dari sumber data (remote atau cache).
///
/// Implementasi tipikal: repository yang wrap API call atau local storage.
///
/// ```dart
/// class UserRepository implements ItemFetcher<User> {
///   @override
///   Future<Result<User>> fetch([bool forceRefresh = false]) async { ... }
/// }
/// ```
abstract interface class ItemFetcher<T> {
  /// Mengambil satu item bertipe [T].
  ///
  /// Jika [forceRefresh] adalah `true`, implementasi harus bypass cache
  /// dan mengambil data terbaru dari sumber utama (biasanya remote).
  ///
  /// Returns [Right] berisi data jika berhasil,
  /// atau [Left] berisi [Failure] jika terjadi error.
  Result<T> fetch([bool forceRefresh = false]);
}

/// Kontrak untuk mengambil koleksi item dari sumber data.
///
/// Gunakan ini untuk list/feed yang bisa di-cache atau di-refresh.
abstract interface class ListFetcher<T> {
  /// Mengambil semua item bertipe [T] sebagai [List].
  ///
  /// Jika [forceRefresh] adalah `true`, implementasi harus bypass cache
  /// dan mengambil data terbaru dari sumber utama.
  ///
  /// Returns [Right] berisi `List<T>` jika berhasil,
  /// atau [Left] berisi [Failure] jika terjadi error.
  Result<List<T>> fetchAll([bool forceRefresh = false]);
}

/// Kontrak untuk menyimpan dan membaca data dari local storage.
///
/// Dirancang untuk cache layer — biasanya diimplementasikan
/// dengan Hive, SharedPreferences, atau in-memory store.
///
/// ```dart
/// class UserCacheStorage implements CacheStorage<User> {
///   @override
///   Result<Unit> save(User data) { ... }
///
///   @override
///   User? read() { ... }
/// }
/// ```
abstract interface class CacheStorage<T> {
  /// Menyimpan [data] ke local storage.
  ///
  /// Returns [Right] berisi [Unit] jika berhasil,
  /// atau [Left] berisi [CacheFailure] jika gagal.
  Result<Unit> save(T data);

  /// Membaca data dari local storage.
  ///
  /// Returns `null` jika data belum pernah disimpan atau sudah expired.
  /// Tidak melempar exception — error handling ada di [save].
  T? read();
}

/// Kontrak untuk melakukan HTTP request.
///
/// Abstraksi di atas HTTP client (Dio, http, dll) agar
/// implementasi bisa diganti tanpa mengubah layer di atasnya.
///
/// Semua method mengembalikan [HTTPResult] — alias dari
/// `Either<Failure, Map<String, dynamic>>` — sehingga
/// error handling konsisten tanpa try-catch di luar layer ini.
abstract interface class HTTPRequest {
  /// Melakukan HTTP GET ke [url].
  ///
  /// - [url] endpoint tujuan, relatif terhadap base URL.
  /// - [queryParameters] query string opsional, misal `{'page': 1}`.
  ///
  /// Returns [Right] berisi response body jika status 2xx,
  /// atau [Left] berisi [Failure] jika terjadi error.
  Future<HTTPResult> get(String url, {Map<String, dynamic>? queryParameters});

  /// Melakukan HTTP POST ke [url] dengan [data] sebagai request body.
  ///
  /// - [url] endpoint tujuan.
  /// - [data] body yang akan di-encode sebagai JSON.
  /// - [queryParameters] query string opsional.
  ///
  /// Returns [Right] berisi response body jika status 2xx,
  /// atau [Left] berisi [Failure] jika terjadi error.
  Future<HTTPResult> post(
    String url, {
    Map<String, dynamic>? queryParameters,
    required Map<String, dynamic> data,
  });

  /// Melakukan HTTP PUT ke [url] dengan [data] sebagai request body.
  ///
  /// Gunakan untuk update resource secara keseluruhan (full replace).
  /// Untuk partial update, pertimbangkan menambahkan method `patch`.
  ///
  /// - [url] endpoint tujuan.
  /// - [data] body yang akan di-encode sebagai JSON.
  /// - [queryParameters] query string opsional.
  ///
  /// Returns [Right] berisi response body jika status 2xx,
  /// atau [Left] berisi [Failure] jika terjadi error.
  Future<HTTPResult> put(
    String url, {
    Map<String, dynamic>? queryParameters,
    required Map<String, dynamic> data,
  });

  /// Melakukan HTTP DELETE ke [url].
  ///
  /// Returns [Unit] jika berhasil.
  /// Jika response non-2xx, implementasi harus melempar atau menangani error.
  Future<Unit> delete(String url);
}
