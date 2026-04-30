// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../types.dart';

/// Kontrak buat narik data sebiji doang dari mana aja (API atau cache lokal).
///
/// Biasanya dipake sama Repository buat bungkus urusan manggil API. Jadi
/// siapapun yang pake class ini udah tau beres cara ambil datanya.
///
/// Contohnya gini:
/// ```dart
/// class UserRepository implements ItemFetcher<User> {
///   @override
///   Future<Result<User>> fetch([bool forceRefresh = false]) async { ... }
/// }
/// ```
abstract interface class ItemFetcher<T> {
  /// Narik data sebiji bertipe [T].
  ///
  /// Kalau [forceRefresh] diset jadi `true`, kita bakal skip cache dan
  /// langsung nodong data terbaru dari sumber utama (kayak API).
  ///
  /// Returns [Result] isinya data kalau aman, atau [Failure] kalau lagi apes.
  Future<Result<T>> fetch([bool forceRefresh = false]);
}

/// Kontrak buat narik data se-gudang (List) dari mana aja.
///
/// Pas banget buat fitur yang ada list-nya, feed, atau koleksi data lainnya.
abstract interface class ListFetcher<T> {
  /// Narik semua data bertipe [T] dalam bentuk [List].
  ///
  /// Kalau [forceRefresh] diset jadi `true`, kita bakal skip data lokal
  /// dan langsung tarik data seger dari pusat.
  ///
  /// Returns [Result] isinya daftar data kalau sukses, atau [Failure] kalau gagal.
  Future<Result<List<T>>> fetchAll([bool forceRefresh = false]);
}

/// Kontrak buat titip data atau baca data di penyimpanan lokal (Cache).
///
/// Ini kayak gudang sementara biar kita nggak usah bolak-balik ke internet.
/// Biasanya di-implement pake Hive, SharedPreferences, atau simpen di memory aja.
///
/// Contoh cara pakenya:
/// ```dart
/// class UserCacheStorage implements CacheStorage<User> {
///   @override
///   Future<Unit> save(User data) { ... }
///
///   @override
///   User? read() { ... }
/// }
/// ```
abstract interface class CacheStorage<T> {
  /// Titip [data] ke penyimpanan lokal biar awet.
  ///
  /// Returns [Unit] kalau proses titipnya berhasil divalidasi lewat [Result].
  Future<Unit> save(T data);

  /// Baca data yang udah pernah dititip sebelumnya.
  ///
  /// Returns `null` kalau datanya emang nggak ada atau udah basi (expired).
  /// Di sini nggak bakal lempar error karena urusan error udah dihandle pas [save].
  T? read();
}

/// Alat tempur buat ngobrol sama server lewat protokol HTTP.
///
/// Ini cuma bungkus (abstraksi) biar kalau kita mau ganti library (misal dari Dio
/// ke http biasa), kode di atasnya nggak perlu ikutan pusing.
/// Semua method di sini bisa lempar [Exception], jadi pastiin dihandle di Repository ya!
abstract interface class HTTPRequest {
  /// Manggil API pake metode GET ke [url].
  ///
  /// Pake [url] yang dituju, dan bisa kasih [queryParameters] kalau mau filter data.
  /// Returns isi responsenya dalam bentuk [Map] kalau status kodenya 2xx (aman).
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  });

  /// Ngirim data baru pake metode POST ke [url] bareng [data].
  ///
  /// [data] bakal otomatis di-encode jadi JSON pas dikirim.
  /// Returns isi response dari server kalau request kita berhasil diproses.
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? queryParameters,
    required Map<String, dynamic> data,
  });

  /// Update data yang udah ada pake metode PUT ke [url] bareng [data].
  ///
  /// Biasanya dipake buat gantiin semua data lama sama data baru yang ada di [data].
  /// Returns hasil kembalian dari server kalau update-nya berhasil.
  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? queryParameters,
    required Map<String, dynamic> data,
  });

  /// Hapus data di [url] yang kita tuju.
  ///
  /// Returns [Unit] kalau server udah setuju datanya dihapus.
  Future<Unit> delete(String url);
}

/// Satpam pintu masuk buat urusan login & logout user.
///
/// Tugasnya jagain sesi user, mulai dari masuk pake kredensial sampai keluar
/// buat bersihin data sesi.
abstract interface class Authenticator<T> {
  /// Proses masuk ke sistem pake [nis] sama [password].
  ///
  /// Bakal ngecek ke server apakah kredensial user valid atau nggak.
  /// Returns [Result] isinya data user [T] kalau berhasil masuk.
  Future<Result<T>> login({required String nis, required String password});

  /// Proses keluar dan akhiri sesi user yang lagi aktif.
  ///
  /// Bakal beresin token atau data sesi di lokal dan server kalau perlu.
  /// Returns [Unit] lewat [Result] kalau proses keluarnya udah beres.
  Future<Result<Unit>> logout();
}
