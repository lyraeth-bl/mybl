# 🔐 Feature: Auth (Si Paling Gerbang Utama)

Selamat datang di markas besar otentikasi! Feature ini tanggung jawabnya gede: mastiin siapa pun
yang masuk ke aplikasi itu beneran user sah, bukan siluman. Kita pake pendekatan **Clean
Architecture** biar kodingannya rapi, nggak numpuk di satu tempat, dan gampang ditest.

---

## 🏗️ Structure Per Layer

Biar nggak bingung pas buka folder, ini pembagian tugas tiap layernya:

### 1. **Domain Layer (Otak Bisnis)**

Ini layer paling suci. Gak boleh ada urusan sama framework atau library luar.

- `entities/`: Blue-print data yang kita pake di aplikasi.
- `repositories/`: Kontrak (interface) buat data. Cuma bilang "Gue butuh fungsi login", tapi gak
  peduli gimana caranya.
- `usecases/`: Si paling spesifik. Satu class, satu tugas (misal: `LoginUseCase`, `SaveNisUseCase`).

### 2. **Data Layer (Tukang Ambil Data)**

Dia yang kerja keras di lapangan buat dapet data.

- `models/`: Versi "kotor" dari entity, biasanya ada fungsi `fromJson` / `toJson` buat urusan sama
  API.
- `datasources/`:
    - `remote/`: Nembak API pake `Dio`.
    - `local/`: Mainan sama `Hive` buat simpen data di dalem HP (kayak simpen NIS).
- `repositories/`: Implementasi dari kontrak di domain. Di sini tempatnya nentuin kapan ambil data
  dari internet, kapan dari lokal.

### 3. **Presentation Layer (Muka & Perasaan)**

Tempat nongkrongnya user.

- `bloc/`: `AuthBloc` (urusan login/logout) & `RememberMeCubit` (urusan centang-centang ingat saya).
- `screens/`: Halaman utama, contohnya `AuthStudentScreen`.
- `widgets/`: Komponen kecil-kecil biar codenya bisa dipake ulang (reusable).

---

## 🔑 Key Classes (Si Paling Penting)

- **[AuthBloc]**: Jantungnya auth. Dia yang dengerin user mau ngapain (Event) terus ngasih tau UI
  harus nampilin apa (State).
- **[LoginUseCase]**: Logic utama pas user mencet tombol login.
- **[AuthRepository]**: Jembatan andalan yang nyambungin antara kebutuhan bisnis sama sumber data.
- **[RememberMeCubit]**: Sipaling inget. Dia yang ngurusin fitur "Remember Me" pake `Hive`.

---

## 🛠️ Dependencies Yang Dipake

- **[flutter_bloc]**: State management andalan biar nggak pusing sama setState.
- **[dio]**: Buat nembak API backend dengan gaya.
- **[hive_ce]**: Database lokal yang cepet banget buat simpen data receh kayak NIS.
- **[freezed]**: Biar nggak capek nulis boilerplate buat State & Model.
- **[get_it]**: Buat Dependency Injection (DI) biar class-class kita nggak saling "ketergantungan"
  secara keras.

---

## 📝 Notes Buat Developer

1. **DI Registration**: Kalo lo nambahin UseCase atau DataSource baru, jangan lupa didaftarin di
   `auth_di.dart` biar bisa dipanggil pake `di<NamaClass>()`.
2. **Error Handling**: Kita pake `fpdart` (Either) buat handle error. Jadi return-nya kalo nggak
   `Left` (Failure), ya `Right` (Success). No more try-catch bertebaran!
3. **Form Validation**: Validasi input di UI tetep perlu, tapi tetep double check logic di Bloc biar
   makin aman.

Kalo ada yang bingung, jangan sungkan buat tanya atau baca dokumentasi di dalem code-nya ya!
