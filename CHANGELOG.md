# Changelog

## [1.0.0] - 2026-06-10

### Features

- Implementasi autentikasi siswa (login/logout)
- Dashboard dengan navigasi utama
- Absensi harian dan bulanan dengan QR code
- Jadwal pelajaran (timetable)
- Kalender akademik
- Nilai akademik
- Ekstrakulikuler
- Poin prestasi (merit) dan pelanggaran (demerit)
- Profil siswa dan detail orang tua/wali
- Push notification via Firebase Cloud Messaging
- Mode maintenance aplikasi
- Pengaturan bahasa dan tema (dark/light mode)
- Splash screen animasi dengan logo Budi Luhur

### Security

- Fix TLS bypass — hanya aktif saat development
- Release signing dengan keystore PKCS12
- Migrasi konfigurasi API dari .env ke dart-define
- Strip password fields dari Hive cache
- Token expiry check di splash screen
- Local session tetap dibersihkan meskipun server logout gagal

### Chore

- Setup flutter_native_splash dengan logo Budi Luhur
- Ganti app icon ke logo Budi Luhur
- Update version ke 1.0.0+1