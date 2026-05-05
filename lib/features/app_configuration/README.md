# 🛠️ Feature: App Configuration

Fitur ini adalah "Si Paling Update" yang tugasnya ngurusin semua konfigurasi aplikasi dari server.
Mulai dari urusan maintenance, update wajib, sampe settings remote lainnya, semuanya diatur di sini.

## 🏗️ Struktur Folder

- **Data**: Tempat beraksinya para penambang data.
    - `datasources/`: Ada yang fokus ambil dari internet (Remote) dan ada yang jagain gudang di HP (
      Local).
    - `models/`: Bentuk mentah data dari API sebelum dipoles.
    - `repositories/`: Jembatan andalan yang ngatur kapan pake data lokal atau narik dari server.
- **Domain**: Otak dari fitur ini.
    - `entities/`: Data yang udah rapi dan siap dipake sama UI.
    - `repositories/`: Kontrak kerja (Interface) biar layer data tau apa yang harus dilakuin.
    - `usecases/`: Jasa titip buat manggil aksi spesifik (misal: `FetchAppConfig`).
- **Presentation**: Wajah dari fitur ini.
    - `bloc/`: Si paling sibuk yang ngatur state UI (loading, success, failure).

## 🚀 Cara Pakai

Cukup panggil `AppConfigurationBloc` di UI lo, terus kirim event `AppConfigurationRequested`.

```dart
context.read<AppConfigurationBloc>
().add
(
const
AppConfigurationEvent
.
requested
(
)
);
```

Kalau mau bener-bener ambil yang fresh dari server tanpa peduli cache:

```dart
context.read<AppConfigurationBloc>
().add
(
const AppConfigurationEvent.requested(forceRefresh: true));
```

## 🛠️ Tech Stack & Library

- **Bloc**: Buat manajemen state yang rapi.
- **Hive**: Gudang penyimpanan lokal biar tetep kenceng.
- **Fpdart**: Biar kodingan lebih aman pake functional programming (Either/Result).
- **Freezed**: Buat bikin data class yang "anti-ribet" (Immutable & Union types).
