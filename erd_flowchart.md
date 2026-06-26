# Dokumen Arsitektur: ERD & Flowchart MaMo (Map Mobile Explorer)

Dokumen ini berisi penjelasan dan representasi visual dari **Entity Relationship Diagram (ERD)** serta **Flowchart** dari alur kerja utama aplikasi **MaMo**. 

---

## 1. Entity Relationship Diagram (ERD)

Aplikasi **MaMo** menggunakan **SQLite** (melalui package `sqflite`) sebagai penyimpanan lokal dengan database bernama `ujikom_mobile.db`. Terdapat 2 tabel utama dalam database ini:
1. **`users`**: Menyimpan data akun pengguna untuk keperluan registrasi, login, dan profil.
2. **`destinasi`**: Menyimpan data destinasi/lokasi tujuan yang ditambahkan oleh user, termasuk koordinat (latitude & longitude) untuk integrasi peta, serta status favorit.

Berikut adalah diagram relasi entitasnya (ERD). 

> [!NOTE]
> Karena aplikasi ini berjalan sepenuhnya lokal di satu perangkat, data destinasi bersifat global per perangkat dan tidak dibatasi secara spesifik per-user (tidak menggunakan relasi foreign key eksplisit di SQLite). Namun, aplikasi secara logis membagi data ini untuk fungsionalitas pengguna.

```mermaid
erDiagram
    USERS {
        INTEGER id PK "AUTOINCREMENT"
        TEXT nama
        TEXT email "UNIQUE"
        TEXT password
        TEXT profile_image_path
    }

    DESTINASI {
        INTEGER id PK "AUTOINCREMENT"
        TEXT nama_tempat
        TEXT deskripsi
        REAL latitude
        REAL longitude
        INTEGER is_favorite "DEFAULT 0"
        TEXT image_path
    }
```

### Penjelasan Detail Field Tabel

#### Tabel `users`
* **`id` (INTEGER, PK)**: Identifier unik untuk setiap user (auto increment).
* **`nama` (TEXT)**: Nama lengkap pengguna.
* **`email` (TEXT, UNIQUE)**: Alamat email pengguna untuk login (tidak boleh kembar).
* **`password` (TEXT)**: Sandi keamanan akun pengguna.
* **`profile_image_path` (TEXT)**: Lokasi path gambar profil di direktori penyimpanan lokal HP.

#### Tabel `destinasi`
* **`id` (INTEGER, PK)**: Identifier unik untuk setiap destinasi (auto increment).
* **`nama_tempat` (TEXT)**: Nama tempat atau alamat lokasi destinasi.
* **`deskripsi` (TEXT)**: Keterangan tambahan atau catatan mengenai lokasi tersebut.
* **`latitude` (REAL)**: Koordinat lintang lokasi (didapatkan secara otomatis melalui geocoding alamat).
* **`longitude` (REAL)**: Koordinat bujur lokasi (didapatkan secara otomatis melalui geocoding alamat).
* **`is_favorite` (INTEGER)**: Status favorit tempat (`1` = Favorit, `0` = Biasa).
* **`image_path` (TEXT)**: Lokasi path gambar destinasi di direktori lokal HP.

---

## 2. Flowchart Alur Kerja Utama

Berikut adalah diagram alur logika pemrograman aplikasi MaMo yang dibagi berdasarkan modul fitur utama.

### A. Alur Registrasi, Login, dan Lupa Password
Flowchart ini menjelaskan proses dari aplikasi pertama kali dibuka, pengecekan session login pengguna, registrasi akun baru, hingga mekanisme reset password jika lupa.

```mermaid
graph TD
    Start([Mulai]) --> OpenApp[Buka Aplikasi MaMo]
    OpenApp --> CheckLogin{Apakah Sudah Login?<br><i>Cek SharedPreferences</i>}
    
    CheckLogin -- Ya --> HomeScreen[Masuk ke Halaman Utama / HomeScreen]
    CheckLogin -- Tidak --> LoginScreen[Halaman Login]
    
    %% Alur Login
    LoginScreen --> InputLogin[Input Email & Password]
    InputLogin --> BtnLogin{Klik Tombol Login}
    BtnLogin --> ValidateLogin{Validasi Database:<br>Email & Password Cocok?}
    ValidateLogin -- Ya --> SaveSession[Simpan Status Login & User ID ke SharedPreferences]
    SaveSession --> HomeScreen
    ValidateLogin -- Tidak --> ShowError[Tampilkan SnackBar: Email/Password Salah] --> LoginScreen
    
    %% Alur Register
    LoginScreen --> ClickRegister[Klik Link Register] --> RegisterScreen[Halaman Register]
    RegisterScreen --> InputRegister[Input Nama, Email, & Password]
    InputRegister --> BtnRegister{Klik Register}
    BtnRegister --> CheckRegEmail{Apakah Email Sudah Terdaftar?}
    CheckRegEmail -- Ya --> ShowRegError[Tampilkan SnackBar: Email Sudah Digunakan] --> RegisterScreen
    CheckRegEmail -- Tidak --> SaveUser[Simpan Data User ke Tabel Users SQLite]
    SaveUser --> ShowRegSuccess[Tampilkan SnackBar Sukses] --> LoginScreen
    
    %% Alur Lupa Password
    LoginScreen --> ClickForgot[Klik Lupa Password] --> ForgotSheet[Reset Password BottomSheet]
    ForgotSheet --> InputForgot[Input Email Terdaftar & Password Baru]
    InputForgot --> BtnForgot{Klik Perbarui Password}
    BtnForgot --> CheckForgotEmail{Cek Database:<br>Email Terdaftar?}
    CheckForgotEmail -- Ya --> UpdateForgotPass[Update Password Baru di Tabel Users]
    UpdateForgotPass --> CloseForgot[Tutup BottomSheet & Tampilkan Pesan Sukses] --> LoginScreen
    CheckForgotEmail -- Tidak --> ShowForgotError[Tampilkan SnackBar: Email Tidak Terdaftar] --> ForgotSheet
```

---

### B. Alur Utama Navigasi (HomeScreen) & CRUD Destinasi
Flowchart ini memetakan menu navigasi utama (Dashboard, Peta Eksplorasi, Favorit, Profil) dan proses lengkap manajemen data destinasi (Create, Read, Update, Delete) yang diintegrasikan dengan Geocoding alamat.

```mermaid
graph TD
    HomeScreen[Masuk ke HomeScreen] --> Navbar{Pilih Menu di Curved Navigation Bar}
    
    %% HUBUNGAN NAVIGASI
    Navbar -->|Index 0| Dashboard[Dashboard Screen]
    Navbar -->|Index 1| Explore[Eksplor Screen - Map]
    Navbar -->|Index 2| Favorites[Fav Screen - Favorit]
    Navbar -->|Index 3| Profile[Profile Screen]
    
    %% ==========================================
    %% ALUR DASHBOARD & CRUD
    %% ==========================================
    Dashboard --> LoadDestinasi[Ambil Semua Destinasi dari SQLite]
    LoadDestinasi --> DisplayList[Tampilkan List Destinasi]
    
    %% Toggle Favorit
    DisplayList --> ClickFav[Klik Tombol Hati] --> ToggleFav[Update is_favorite di SQLite] --> ReloadDashboard[Segarkan Tampilan Dashboard]
    
    %% Buka Google Maps
    DisplayList --> ClickMaps[Klik Tombol Navigasi/Maps] --> LaunchMaps[Launch URL Google Maps dengan Nama Tempat]
    
    %% Hapus Destinasi
    DisplayList --> ClickDelete[Klik Tombol Hapus] --> DeleteDestinasi[Hapus Destinasi dari SQLite] --> ReloadDashboard
    
    %% Form Tambah / Edit Destinasi (C & U)
    DisplayList --> ClickForm[Klik Tambah / Edit Destinasi] --> FormSheet[BottomSheet Form Destinasi]
    FormSheet --> InputForm[Input Nama Tempat, Deskripsi & Pilih Foto]
    InputForm --> SubmitForm{Klik Simpan / Update}
    
    SubmitForm --> ShowLoading[Tampilkan Loading Dialog]
    ShowLoading --> GeocodingProcess[Cari Koordinat via Geocoding: 'Nama Tempat + Indonesia']
    GeocodingProcess --> GeocodingSuccess{Sukses Ditemukan?}
    
    GeocodingSuccess -- Ya --> SetCoords[Set Latitude & Longitude Asli]
    GeocodingSuccess -- Tidak --> SetDefaultCoords[Set Lat: 0.0, Lng: 0.0 / Pertahankan Koordinat Lama]
    
    SetCoords --> SaveProcess{Apakah Data Baru?}
    SetDefaultCoords --> SaveProcess
    
    SaveProcess -- Ya --> InsertSQL[Insert Data ke Tabel Destinasi]
    SaveProcess -- Tidak --> UpdateSQL[Update Data di Tabel Destinasi berdasarkan ID]
    
    InsertSQL --> CloseForm[Tutup BottomSheet & Dialog Loading] --> ReloadDashboard
    UpdateSQL --> CloseForm
```

---

### C. Alur Eksplorasi Peta (Explore Screen)
Flowchart ini menjelaskan bagaimana data koordinat destinasi yang tersimpan di SQLite dipetakan menggunakan `flutter_map` (OpenStreetMap) bersamaan dengan posisi GPS real-time pengguna.

```mermaid
graph TD
    Explore[Buka Menu Eksplor Peta] --> RequestGPS[Minta Izin Akses GPS & Lokasi Perangkat]
    RequestGPS --> GPSAllowed{Apakah Izin Diberikan?}
    
    GPSAllowed -- Ya --> GetCurrentLoc[Dapatkan Posisi Lat & Lng Sekarang]
    GPSAllowed -- Tidak --> DefaultLoc[Gunakan Koordinat Default Jember:<br>-8.1699975, 113.7214757]
    
    GetCurrentLoc --> LoadMap[Render Peta OSM & Posisikan Kamera Utama]
    DefaultLoc --> LoadMap
    
    LoadMap --> FetchDestinasi[Ambil Semua Data Destinasi dari SQLite]
    FetchDestinasi --> DrawPins[Gambar Pin pada Peta:<br>1. Pin Merah: Lokasi User<br>2. Pin Biru: Daftar Destinasi]
    
    DrawPins --> ClickPin[User Klik Salah Satu Pin Destinasi]
    ClickPin --> ShowInfoSheet[Tampilkan BottomSheet Info Detail Destinasi<br><i>Nama Tempat, Deskripsi, & Foto</i>]
```

---

### D. Alur Profil & Manajemen Perubahan
Flowchart ini mengilustrasikan proses edit profil pengguna, penggantian foto profil, dan validasi penting sebelum pengguna meninggalkan halaman profil jika ada data yang belum disimpan.

```mermaid
graph TD
    Profile[Buka Menu Profil] --> LoadUser[Ambil Data & Foto Profil dari SQLite]
    LoadUser --> DisplayProfile[Tampilkan Nama, Email, & Foto Profil]
    
    DisplayProfile --> EditFields[Edit Nama / Ganti Foto via ImagePicker / Edit Password]
    
    %% Alur Deteksi Unsaved Changes
    EditFields --> UserLeaves{User Mencoba Pindah Menu Navigation Bar?}
    UserLeaves -- Ya --> CheckChanges{Apakah Ada Perubahan Data<br>Yang Belum Disimpan?}
    
    CheckChanges -- Ya --> WarningDialog[Tampilkan Dialog Konfirmasi:<br><i>'Perubahan Belum Disimpan'</i>]
    WarningDialog --> ChooseStay{Pilih Batal / Tinggalkan?}
    ChooseStay -- Batal --> StayOnProfile[Tetap di Halaman Profil & Navbar Revert ke Index 3] --> Profile
    ChooseStay -- Tinggalkan --> GoToNewMenu[Pindah ke Halaman Baru Sesuai Menu Yang Dipilih]
    
    CheckChanges -- Tidak --> GoToNewMenu
    UserLeaves -- Tidak --> SaveProfile{Klik Tombol Simpan Perubahan}
    
    %% Simpan Profil
    SaveProfile --> SaveProfileDB[Update Nama, Password, & Path Foto di Tabel Users]
    SaveProfileDB --> ShowSaveSuccess[Tampilkan SnackBar Sukses] --> LoadUser
    
    %% Logout
    DisplayProfile --> ClickLogout[Klik Tombol Logout]
    ClickLogout --> ConfirmLogout{Konfirmasi Logout?}
    ConfirmLogout -- Ya --> ClearPrefs[Hapus Seluruh Data SharedPreferences]
    ClearPrefs --> RedirectLogin[Pindah ke Login Screen & Hapus Riwayat Navigasi]
    ConfirmLogout -- Tidak --> Profile
```
