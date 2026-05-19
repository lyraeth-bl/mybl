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

/// Kontrak buat titip data atau baca data se-gudang (List) di penyimpanan lokal.
///
/// Fungsinya mirip [CacheStorage], tapi khusus buat nanganin sekumpulan data [T].
/// Berguna banget buat nyimpen hasil fetch list dari API biar bisa dibaca offline.
abstract interface class ListCacheStorage<T> {
  /// Titip daftar data [listData] ke penyimpanan lokal.
  ///
  /// Returns [Unit] kalau proses nyimpennya udah beres.
  Future<Unit> save(List<T> listData);

  /// Baca daftar data yang udah pernah dititip sebelumnya.
  ///
  /// Returns `null` kalau datanya emang nggak ada atau box-nya masih kosong.
  List<T>? read();
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

/// Jembatan buat nyimpen info "ingat saya" (biasanya nis) biar
/// user nggak capek ngetik ulang tiap kali mau login.
///
/// Ini ngebantu banget buat user experience karena mereka tinggal isi password
/// aja pas mau masuk lagi.
abstract interface class RememberMeStorage {
  /// Ngintip data nis yang udah pernah dititip sebelumnya.
  ///
  /// Kalau dapet, kita bisa langsung isiin ke field nis di halaman login.
  /// Returns [String] kalau ada, atau `null` kalau emang lagi kosong.
  Future<String?> readNIS();

  /// Nitip [nis] ke storage biar besok-besok bisa langsung muncul.
  ///
  /// Biasanya dipanggil pas user berhasil login dan centang opsi "Remember Me".
  /// Returns [Unit] kalau proses nyimpennya udah beres.
  Future<Unit> saveNIS(String nis);
}

/// Brangkas rahasia buat nyimpen token akses biar user nggak usah login berkali-kali.
///
/// Ini tugasnya jagain [accessToken] yang kita dapet dari server. Jadi selama tokennya
/// masih ada dan valid, user bisa bebas mondar-mandir di app tanpa diganggu satpam login.
abstract interface class TokenStorage {
  /// Ngintip token yang lagi kita pegang sekarang.
  ///
  /// Returns [String] tokennya kalau ada, atau `null` kalau emang lagi nggak ada sesi
  /// yang aktif (alias user lagi logout).
  Future<String?> readAccessToken();

  /// Titip [accessToken] baru ke brangkas pas user berhasil login.
  ///
  /// Begitu token ini disimpen, app bakal pake ini buat semua urusan yang butuh
  /// izin khusus dari server.
  Future<Unit> saveAccessToken(String accessToken);

  /// Bakar atau buang token yang ada pas user milih buat logout.
  ///
  /// Ini penting banget buat keamanan biar nggak ada orang iseng yang bisa
  /// masuk pake sesi lama yang udah nggak dipake.
  Future<Unit> clearAccessToken();
}

/// Si paling sibuk buat urusan manajemen gudang (database lokal).
///
/// Tugasnya simpel tapi krusial: mastiin semua pintu penyimpanan (boxes)
/// siap dibuka pas app baru mulai, dibersihin pas user logout, atau digembok
/// rapi pas app mau istirahat.
abstract interface class LocalStorageManager {
  /// Nyiapin dan buka semua pintu penyimpanan biar data siap dieksekusi.
  ///
  /// Biasanya dipanggil sekali pas proses inisialisasi awal app.
  Future<void> openAllBoxes();

  /// Sapu bersih semua data yang ada di dalem penyimpanan.
  ///
  /// Berguna banget buat jaga-jaga kalau user mau reset data atau pas logout
  /// biar nggak ada sisa-sisa kenangan (data) yang ketinggalan.
  Future<void> clearAllBoxes();

  /// Gembok semua pintu penyimpanan pas udah selesai dipake.
  ///
  /// Ini penting biar database kita nggak korup dan tetep sehat walafiat.
  Future<void> closeAllBoxes();
}

/// Spesialis urusan tarik-menarik data absensi.
///
/// Interface ini jadi andalan buat ambil info kehadiran, baik itu buat hari ini
/// atau buat ngintip rekap sebulan penuh.
abstract interface class AttendanceFetcher<T> {
  /// Ngintip status kehadiran buat hari ini doang bertipe [T].
  ///
  /// Kalau [forceRefresh] diset jadi `true`, kita bakal todong data paling
  /// gress langsung dari server (bye-bye cache).
  ///
  /// Returns [Result] isinya data hari ini kalau lancar jaya,
  /// atau `null` kalau user belum absen hari ini.
  Future<Result<T?>> fetchDailyAttendance([bool forceRefresh = false]);

  /// Narik semua data kehadiran dalam satu bulan tertentu.
  ///
  /// Butuh input [month] sama [year] biar nggak salah ambil bulan tetangga.
  /// Sama kayak sodaranya, [forceRefresh] bakal maksa ambil data terbaru dari pusat.
  ///
  /// Returns [Result] isinya list data [T] buat bulan yang diminta.
  Future<Result<List<T>>> fetchMonthlyAttendance({
    required int month,
    required int year,
    bool forceRefresh = false,
  });
}

/// Spesialis urusan titip-menitip data absensi ke memori lokal.
///
/// Ini adalah asisten setia buat [AttendanceFetcher]. Kalau [AttendanceFetcher] tugasnya
/// nodong data ke server, [AttendanceLocalManager] tugasnya jagain data itu biar
/// tetep aman di dalem box (storage) lokal. Jadi pas user buka app lagi,
/// datanya udah siap tampil tanpa perlu nunggu loading internet.
abstract interface class AttendanceLocalManager<T> {
  /// Nyimpen data rekap absensi bulanan ke dalam brangkas lokal.
  ///
  /// Panggil ini pas kita udah dapet data seger dari API biar kalau besok-besok
  /// HP lagi offline, kita tetep bisa pamer data absensi bulanannya.
  Future<Unit> saveMonthlyAttendance({
    required int month,
    required int year,
    required List<T> listData,
  });

  /// Ngamanin data absensi hari ini biar nggak ilang.
  ///
  /// Mirip kayak sodaranya, ini fokus buat simpen status kehadiran yang paling
  /// baru (hari ini) ke penyimpanan lokal.
  Future<Unit> saveDailyAttendance(T data);

  /// Ngambil data rekap bulanan yang udah pernah kita simpen sebelumnya.
  ///
  /// Kita kasih [listData] sebagai referensi, terus fungsi ini bakal balikin
  /// data yang emang udah ada di lokal. Kalau kosong, ya berarti emang belum
  /// pernah mampir datanya.
  List<T>? readMonthlyAttendance({required int month, required int year});

  /// Nyari data absensi harian yang udah tersimpan di lokal.
  ///
  /// Pake [data] buat nyocokin, terus kita liat apakah di "gudang" kita ada
  /// data yang pas atau nggak. Returns `null` kalau emang nggak nemu.
  T? readDailyAttendance();
}

/// Spesialis urusan titip-menitip jadwal pelajaran ke penyimpanan lokal.
///
/// Interface ini bertugas buat jagain data jadwal pelajaran (TimeTable) biar
/// tetep bisa diintip meskipun HP lagi nggak ada sinyal. Mirip kayak gudang
/// buat nyimpen peta perjalanan biar nggak nyasar pas offline.
abstract interface class TimeTableLocalManager<T> {
  /// Titip daftar jadwal pelajaran [listData] ke dalem storage lokal.
  ///
  /// Panggil ini pas kita baru aja dapet jadwal paling fresh dari internet.
  Future<Unit> saveListTimeTable({required List<T> listData});

  /// Ngambil daftar jadwal pelajaran yang udah pernah kita titip sebelumnya.
  ///
  /// Returns list data [T] kalo ada isinya, atau `null` kalo emang gudangnya
  /// lagi kosong melompong.
  List<T>? readListTimeTable();
}
