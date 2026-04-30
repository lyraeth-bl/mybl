# Panduan Internasionalisasi: GetX vs Flutter Localizations

Dokumen ini menjelaskan perbedaan, cara penggunaan, dan alasan mengapa proyek ini menggunakan
Flutter Localizations (ARB) dibandingkan GetX Translations.

## 1. Perbandingan Singkat

| Fitur             | GetX Translations                             | Flutter Localizations (Proyek Ini)         |
|:------------------|:----------------------------------------------|:-------------------------------------------|
| **Format File**   | Map Dart (`Map<String, Map<String, String>>`) | ARB (Application Resource Bundle - JSON)   |
| **Type Safety**   | Tidak (menggunakan String key `'hello'.tr`)   | **Ya** (menggunakan properti `l10n.hello`) |
| **Standardisasi** | Spesifik untuk ekosistem GetX                 | Standar resmi Flutter & industri           |
| **Tooling**       | Manual                                        | Auto-generate kode Dart dari ARB           |
| **Kompilasi**     | Runtime (error muncul saat aplikasi jalan)    | Compile-time (error muncul saat coding)    |

---

## 2. Flutter Localizations (Cara Pakai di Proyek Ini)

Proyek ini menggunakan standar Flutter dengan file `.arb` yang terletak di `lib/l10n/`.

### Cara Menambah Pesan Baru

1. Buka file `lib/l10n/app_id.arb` (Bahasa Indonesia) atau `app_en.arb` (Bahasa Inggris).
2. Tambahkan key dan value baru:
   ```json
   "welcomeMessage": "Selamat datang di Budi Luhur"
   ```
3. Jalankan `flutter gen-l10n` (atau biasanya auto-generate saat save di IDE).

### Cara Penggunaan di Kode

Anda mendapatkan *Type Safety* penuh, sehingga IDE akan memberikan saran (auto-complete).

```dart
// Import lokalisasi
import 'package:my_bl/l10n/app_localizations.dart';

// Di dalam build method
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return Text(l10n.dioNetworkError); // IDE akan tahu jika key ini ada atau tidak
}
```

---

## 3. GetX Translations (Cara Kerja)

GetX menggunakan pendekatan yang lebih sederhana namun kurang aman secara tipe data.

### Cara Definisi

```dart
class MyTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys =>
      {
        'en_US': {'hello': 'Hello'},
        'id_ID': {'hello': 'Halo'},
      };
}
```

### Cara Penggunaan

```dart
Text
('hello
'
.tr); // 'tr' adalah extension method dari GetX
```

---

## 4. Mengapa Memilih Flutter Localizations?

1. **Keamanan Tipe (Type Safety)**: Jika Anda salah ketik key di GetX (`'helo'.tr`), aplikasi tidak
   akan error tapi hanya menampilkan teks mentah. Di Flutter Localizations, kode tidak akan bisa
   di-compile jika key salah.
2. **Dukungan Plural & Placeholder**: ARB mendukung penanganan kata jamak (Plurals) dan variabel di
   dalam teks dengan sangat rapi sesuai standar ICU.
3. **Pemisahan File**: Dengan file ARB, Anda bisa memberikan file tersebut ke penerjemah profesional
   tanpa mereka harus menyentuh kode Dart.
4. **Performa**: Flutter Localizations menghasilkan kelas Dart yang sangat efisien dan dioptimalkan
   oleh Flutter.

## 5. Kapan Pakai GetX?

GetX cocok untuk proyek kecil atau prototype cepat yang tidak memerlukan validasi ketat saat
kompilasi. Namun, untuk aplikasi skala besar seperti **my_bl**, Flutter Localizations jauh lebih
stabil dan mudah dipelihara.
