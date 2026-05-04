# 👤 Feature: User (Si Paling Profil)

Selamat datang di markas besar fitur **User**! Di sini tempat berkumpulnya semua logika yang
berhubungan sama data profil siswa. Fitur ini dirancang pake arsitektur yang rapi biar lo nggak
pusing pas mau *maintenance* atau nambah fitur baru.

---

## 🧐 Apaan sih ini?

Fitur ini punya tanggung jawab buat ngurusin segala hal tentang identitas siswa. Mulai dari narik
data lengkap dari server, nyimpen di cache lokal biar aplikasi berasa ngebut, sampe nyediain data
siap pakai buat ditampilin di layar profil atau dashboard.

---

## 🏗️ Structure Per Layer

Biar nggak bingung pas buka folder, ini pembagian tugas tiap layernya:

### 1. **Domain Layer (Otak Bisnis)**

Ini layer paling suci. Gak boleh ada urusan sama framework atau library luar.

- `entities/`: [StudentEntity] adalah blueprint data siswa yang paling bersih dan lengkap.
- `repositories/`: [UserRepository] cuma kontrak atau janji doang yang bilang "Gue butuh cara buat
  ambil data siswa".
- `usecases/`: [FetchStudentUseCase] si kurir andalan yang tugas spesifiknya cuma jemput data siswa.

### 2. **Data Layer (Kuli Angkut)**

Dia yang kerja keras di lapangan buat dapet data mentah.

- `models/`: [StudentModel] & [StudentResponse] itu versi "kotor" dari entity, tugasnya sulap data
  dari JSON API.
- `datasources/`:
    - `remote/`: [UserRemoteDataSource] nembak API pake `Dio` (lewat `HTTPRequest`).
    - `local/`: [UserLocalDataSource] mainan sama `Hive` buat simpen data detail siswa di dalem HP.
- `repositories/`: [UserRepositoryImpl] adalah mandor yang ngatur kapan ambil data dari internet,
  kapan dari lokal (caching logic).

### 3. **Presentation Layer (Wajah & Perasaan)**

Tempat buat ngatur apa yang diliat sama user.

- `bloc/`: [UserBloc] adalah pusat kendali. UI tinggal dengerin [UserState] dan kirim [UserEvent].

---

## 🚀 Cara Pake

Kalo lo mau ambil data user di UI, langkahnya simpel:

1. **Kirim Event**:
   ```dart
   context.read<UserBloc>().add(const UserEvent.fetchStudentRequested());
   ```
2. **Pantau State**:
   Pake `BlocBuilder` atau `BlocListener` buat nampilin datanya:
   ```dart
   state.when(
     success: (student) => Text('Halo, ${student.namaPanggilan}!'),
     failure: (f) => Text('Waduh, error: ${f.message}'),
     loading: () => const CircularProgressIndicator(),
     initial: () => const SizedBox(),
   );
   ```

---

## 🛠️ Dependencies Yang Dipake

- **[flutter_bloc]**: State management biar alur data di UI jelas.
- **[hive_ce]**: Database lokal buat caching data profil biar gak dikit-dikit nembak API.
- **[freezed]**: Biar gak capek nulis boilerplate buat State, Event, dan Model.
- **[fpdart]**: Buat handle error pake `Either` (Functional Programming style).

---

## 📝 Notes Buat Developer

1. **DI Registration**: Semua komponen "dijodohin" di [initUserDI] yang ada di file `user_di.dart`.
   Kalo nambahin class baru, jangan lupa daftarin di sana!
2. **Caching Logic**: Secara default, repository bakal cek data di lokal dulu. Kalo lo mau maksa
   ambil data fresh dari server, kirim event dengan `forceRefresh: true`.
3. **Mapper**: Kita pake [StudentModelMapper] buat ubah data mentah API jadi Entity. Jangan pernah
   pake Model langsung di layer Domain atau UI ya!

---
*Dokumentasi ini ditulis dengan gaya "The Relatable Dev" biar lo gak ngantuk baca dokumentasi
teknis.* ✌️
