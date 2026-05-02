# 🔐 Features: Sessions

Selamat datang di **Sessions**, fitur yang jadi "Satpam" sekaligus "Brangkas" utama di aplikasi ini.
Tugasnya simpel tapi krusial: jagain status login user biar nggak gampang jebol dan bikin user nggak
usah login berkali-kali setiap buka app.

---

## 🧐 Apaan sih ini?

Fitur ini ngurusin segala hal yang berhubungan sama **Access Token**. Mulai dari nyimpen token pas
user baru login, ngecek token pas app baru nyala, sampe "ngebakar" token pas user milih buat logout.
Semuanya dijagain pake enkripsi biar aman sentosa.

---

## 🏗️ Struktur Dalemannya

Kita pake Clean Architecture biar rapi jali. Berikut adalah peta biar lo nggak nyasar:

### 1. 📂 Domain (Otak Bisnis)

Isinya aturan main gimana sesi harus bekerja.

- **Repositories**: Kontrak (`SessionRepository`) yang bilang "Pokoknya gue butuh cara buat simpen,
  baca, dan hapus token!".
- **Use Cases**: Si pelaksana tugas spesifik.
    - `ReadAccessTokenUseCase`: Si Tukang Ngintip token.
    - `SaveAccessTokenUseCase`: Jembatan buat nitipin token baru.
    - `ClearAccessTokenUseCase`: Si paling beres-beres pas logout.

### 2. 📂 Data (Kuli Angkut)

Tempat kerjaan kasar dilakuin.

- **Repositories Impl**: Implementasi nyata dari kontrak di Domain. Dia jadi "Makelar" antara logic
  dan storage.
- **Data Sources**: Eksekutor yang megang kunci brangkas. Di sini kita pake `FlutterSecureStorage`
  buat nyimpen token secara terenkripsi di dalem OS.

### 3. 📂 Presentation (Wajah Aplikasi)

Gimana status sesi ditampilin dan dikelola buat UI.

- **Bloc**: `SessionBloc` adalah komandannya. Dia dengerin event (kayak `Started`, `LoggedIn`, atau
  `LoggedOut`) terus ngasih tau seluruh aplikasi apakah user lagi `authenticated` atau
  `unauthenticated`.

---

## 🚀 Cara Pake

Biasanya lo bakal sering interaksi sama `SessionBloc`.

- Mau tau user udah login apa belum? Cek state di `SessionBloc`.
- Habis login sukses dari API? Kasih tau `SessionBloc` lewat event `LoggedIn(token)`.
- User mau logout? Panggil event `LoggedOut()`.

---

## 🛡️ Keamanan

Kita nggak main-main soal keamanan. Token **HARAM** hukumnya disimpen di `SharedPreferences` biasa.
Makanya kita pake `FlutterSecureStorage` biar datanya aman di dalem *Keychain* (iOS) atau
*Keystore* (Android).

---

> **Note buat Dev:** Kalau mau nambahin jenis storage lain (misal mau pindah ke database), lo cukup
> bikin implementasi baru di `Data Sources` tanpa perlu ngutak-ngatik logic di `Domain` atau
`Presentation`. Mantap kan? 😎
