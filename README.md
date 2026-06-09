# MyBL

MyBL adalah aplikasi mobile untuk ekosistem layanan siswa Budi Luhur. Aplikasi
ini dibuat sebagai pusat akses informasi akademik dan aktivitas sekolah, supaya
siswa dapat melihat data penting seperti profil, presensi, jadwal pelajaran,
nilai, kalender akademik, ekstrakurikuler, merit/demerit, dan notifikasi dalam
satu aplikasi.

Repository ini berisi source code aplikasi MyBL berbasis Flutter. Di dalamnya
terdapat implementasi fitur aplikasi, integrasi API, manajemen sesi, local
storage, routing, localization, theming, dan notifikasi.

## Tentang Aplikasi

MyBL membantu siswa mengakses informasi sekolah secara lebih cepat dan
terpusat. Aplikasi ini dirancang untuk mendukung kebutuhan harian siswa, mulai
dari mengecek jadwal, memantau presensi, melihat nilai, sampai menerima
notifikasi terbaru dari sistem sekolah.

Secara umum, aplikasi ini berperan sebagai client mobile yang terhubung ke
layanan backend Budi Luhur melalui API SPO dan API internal.

## Fitur Aplikasi

- Login siswa dan manajemen sesi
- Dashboard sebagai halaman utama aplikasi
- Profil siswa
- Detail wali atau orang tua
- Presensi harian dan riwayat presensi
- Jadwal pelajaran
- Data ekstrakurikuler
- Merit dan demerit siswa
- Kalender akademik
- Nilai akademik
- Notifikasi aplikasi
- Pengaturan tema light/dark
- Pengaturan bahasa Indonesia dan Inggris

## Modul di Repository

Kode aplikasi disusun per fitur di dalam folder `lib/features`.

```text
lib/features/
├── academic_calendar/    # Kalender akademik
├── academic_result/      # Nilai akademik
├── app_configuration/    # Konfigurasi aplikasi
├── attendance/           # Presensi siswa
├── auth/                 # Login dan autentikasi
├── dashboard/            # Halaman utama
├── device_token/         # Registrasi token perangkat
├── discipline/           # Merit dan demerit
├── extracurricular/      # Ekstrakurikuler
├── guardians_detail/     # Detail wali siswa
├── notifications/        # Notifikasi
├── profile/              # Profil siswa
├── sessions/             # Session/auth state
├── settings/             # Pengaturan aplikasi
├── splash/               # Splash screen
├── time_table/           # Jadwal pelajaran
└── user/                 # Data user aktif
```

Folder `lib/core` berisi bagian aplikasi yang dipakai lintas fitur, seperti
routing, dependency injection, API client, storage, theme, localization,
notifikasi, error handling, dan reusable widgets.

## Alur Penggunaan

Saat aplikasi dibuka, MyBL menjalankan proses inisialisasi seperti memuat
environment, Firebase, local storage, dependency injection, dan service
notifikasi. Setelah itu aplikasi akan mengecek sesi user.

Jika user belum login, aplikasi mengarahkan user ke halaman login siswa. Jika
user sudah memiliki sesi aktif, aplikasi akan masuk ke dashboard dan membuka
akses ke fitur-fitur akademik.

## Integrasi

MyBL menggunakan dua base URL utama yang disimpan melalui file `.env`.

```env
BASE_URL=
BASE_URL_INTERNAL=
```

`BASE_URL` digunakan untuk layanan utama SPO, sedangkan `BASE_URL_INTERNAL`
digunakan untuk endpoint internal seperti jadwal pelajaran.

Beberapa integrasi penting di aplikasi:

- REST API untuk data akademik dan profil siswa
- Firebase Core
- Firebase Cloud Messaging
- Local notifications
- Secure storage untuk data sensitif
- Hive storage untuk cache dan data lokal

## Teknologi

Project ini dibangun dengan Flutter dan menggunakan pendekatan Clean
Architecture agar setiap fitur memiliki batas tanggung jawab yang jelas.

Stack utama:

- Flutter
- Dart
- BLoC
- Freezed
- Dio
- GetIt
- GoRouter
- Hive CE
- Flutter Secure Storage
- Firebase Messaging
- Flutter Localizations

## Arsitektur Singkat

Setiap fitur utama umumnya dipisah menjadi tiga layer:

- `domain`: entity, repository contract, dan use case
- `data`: model, data source, dan repository implementation
- `presentation`: BLoC, screen, dan widget

Pola ini membuat business flow berada di use case/repository, sementara UI
tetap fokus pada tampilan dan interaksi user.

## Menjalankan Project

Install dependency:

```bash
flutter pub get
```

Buat file `.env` dari contoh yang tersedia:

```bash
cp .env.example .env
```

Generate file yang dibutuhkan oleh Freezed, JSON Serializable, dan Hive:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Jalankan aplikasi:

```bash
flutter run
```

## Development Notes

- Konfigurasi routing ada di `lib/core/app_router`.
- Konfigurasi dependency injection dimulai dari `lib/core/app/initialize_app.dart`.
- Localization menggunakan file ARB di `lib/l10n`.
- Panduan coding dan struktur Clean Architecture ada di `AGENTS.md`.
- CI project menjalankan dependency install, code generation, format check, dan
  analyze pada pull request ke `dev` atau `main`.
