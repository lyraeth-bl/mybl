// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_student_screen.dart';

part 'route_names.dart';

/// Konfigurasi routing aplikasi menggunakan [GoRouter].
///
/// ---
///
/// ## Kenapa Migrasi dari GetX ke GoRouter?
///
/// Sebelumnya project ini menggunakan GetX untuk routing. Kita migrasi ke
/// GoRouter karena beberapa alasan:
///
/// - **Lebih ringan** — GoRouter hanya fokus ke routing, tidak membawa
///   state management dan dependency injection seperti GetX, jadi tidak ada
///   "magic" yang tersembunyi.
/// - **Declarative & readable** — Semua route didefinisikan di satu tempat,
///   mudah dibaca dan di-trace alurnya.
/// - **Flutter-first** — GoRouter adalah package official dari Flutter team,
///   jadi lebih terjamin maintenance dan kompatibilitasnya ke depan.
/// - **Deep link ready** — Support deep link tanpa konfigurasi tambahan yang
///   rumit.
///
/// ---
///
/// ## Cara Pakai
///
/// ### 1. Navigasi Dasar
///
/// ```dart
/// // GetX (lama) — tidak perlu context
/// Get.toNamed(RouteNames.dashboard);
///
/// // GoRouter (sekarang) — butuh context
/// context.go(RouteNames.dashboard);
/// ```
///
/// ### 2. Replace Halaman (tanpa bisa back)
///
/// ```dart
/// // GetX (lama)
/// Get.offNamed(RouteNames.login);
/// Get.offAllNamed(RouteNames.splash);
///
/// // GoRouter (sekarang)
/// context.go(RouteNames.login); // go() otomatis replace history
/// ```
///
/// > **Catatan:** Di GoRouter, `context.go()` akan replace halaman saat ini
/// > (tidak bisa back), sedangkan `context.push()` akan menumpuk halaman
/// > di atas halaman sebelumnya (bisa back).
///
/// ### 3. Push Halaman (bisa back)
///
/// ```dart
/// // GetX (lama)
/// Get.toNamed(RouteNames.detail);
///
/// // GoRouter (sekarang)
/// context.push(RouteNames.detail);
/// ```
///
/// ### 4. Navigasi dengan Parameter
///
/// ```dart
/// // Path parameter
/// context.go('/user/123');
///
/// // Query parameter
/// context.go('/product?name=sepatu');
///
/// // Ambil parameternya di halaman tujuan
/// final id = GoRouterState.of(context).pathParameters['id'];
/// final name = GoRouterState.of(context).uri.queryParameters['name'];
/// ```
///
/// ### 5. Navigasi tanpa Context (jika terpaksa)
///
/// Sebisa mungkin pakai `context.go()`, tapi kalau memang tidak ada context
/// (misalnya dari service atau bloc), bisa akses instance-nya via DI:
///
/// ```dart
/// di<AppRouter>().goRouter.go(RouteNames.login);
/// ```
///
/// ---
///
/// ## Setup di MaterialApp
///
/// Class ini sudah diregistrasi sebagai singleton di DI, jadi tinggal
/// panggil di `MyBLApp`:
///
/// ```dart
/// MaterialApp.router(
///   routerConfig: di<AppRouter>().goRouter,
/// );
/// ```
///
/// ---
///
/// ## Menambah Route Baru
///
/// Semua nama route didefinisikan di [RouteNames] (file `route_names.dart`).
/// Untuk menambah halaman baru, cukup:
///
/// **1. Tambah nama route di `route_names.dart`:**
/// ```dart
/// static const String profile = '/profile';
/// ```
///
/// **2. Daftarkan route-nya di list `routes` di bawah:**
/// ```dart
/// GoRoute(
///   path: RouteNames.profile,
///   builder: (context, state) => const ProfilePage(),
/// ),
/// ```
///
/// ---
///
/// ## Ringkasan Padanan GetX → GoRouter
///
/// | GetX                        | GoRouter                                   |
/// |-----------------------------|--------------------------------------------|
/// | `Get.toNamed('/x')`         | `context.push('/x')`                       |
/// | `Get.offNamed('/x')`        | `context.go('/x')`                         |
/// | `Get.offAllNamed('/x')`     | `context.go('/x')`                         |
/// | `Get.back()`                | `context.pop()`                            |
/// | `Get.arguments`             | `GoRouterState.of(context).extra`          |
/// | `Get.parameters`            | `GoRouterState.of(context).pathParameters` |
class AppRouter {
  late final GoRouter goRouter = GoRouter(
    initialLocation: RouteNames.splash,

    routes: <GoRoute>[
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) =>
            Scaffold(body: Center(child: Text("Splash Screen"))),
      ),

      GoRoute(
        path: RouteNames.authStudent,
        builder: (context, state) => const AuthStudentScreen(),
      ),
    ],
  );
}
