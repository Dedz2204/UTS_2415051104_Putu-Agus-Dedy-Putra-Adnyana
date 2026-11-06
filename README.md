# PayTrack - Bill and Payment Reminder App

**PayTrack** adalah aplikasi pengelolaan tagihan dan pengingat pembayaran berbasis Flutter. Aplikasi ini dikembangkan untuk membantu pengguna mencatat tagihan, memantau tanggal jatuh tempo, mengelola status pembayaran, serta melihat riwayat pembayaran dalam satu aplikasi.

Aplikasi ini menggunakan Supabase sebagai backend dan database, serta REST API Nager.Date untuk memperoleh informasi hari libur nasional Indonesia.

---

## Identitas Pengembang

Nama : Putu Agus Dedy Putra Adnyana
NIM : 2415051104
Kelas : PTI 5A
Program Studi : Pendidikan Teknik Informatika
Perguruan Tinggi : Universitas Pendidikan Ganesha

---

## Fitur Aplikasi

Berikut fitur utama yang tersedia pada PayTrack:

1. **Dashboard**  
   Menampilkan ringkasan tagihan, total tagihan belum dibayar, dan informasi tagihan mendatang.

2. **Manajemen Tagihan**  
   Memungkinkan pengguna menambahkan, melihat, mengubah, dan menghapus data tagihan.

3. **Pencarian dan Filter Tagihan**  
   Membantu pengguna menemukan tagihan berdasarkan informasi dan status pembayaran.

4. **Detail Tagihan**  
   Menampilkan informasi lengkap mengenai tagihan yang dipilih.

5. **Status Pembayaran**  
   Memungkinkan pengguna mengubah status tagihan menjadi lunas atau belum lunas.

6. **Riwayat Pembayaran**  
   Menampilkan daftar tagihan yang telah diselesaikan.

7. **Informasi Hari Libur Nasional**  
   Mengambil dan menampilkan informasi hari libur nasional Indonesia melalui REST API.

8. **Profil Pengguna**  
   Menyediakan halaman informasi aplikasi dan pengelolaan profil sederhana.

9. **Responsive Layout**  
   Mendukung tampilan pada perangkat mobile, tablet, dan desktop.

---

## Tech Stack

Teknologi dan Fungsi 

Flutter : Framework pengembangan aplikasi 
Dart : Bahasa pemrograman 
Material Design 3 : Desain antarmuka aplikasi 
Provider : State management 
Supabase : Backend dan database 
PostgreSQL : Sistem basis data 
HTTP : Komunikasi dengan REST API 
SharedPreferences : Penyimpanan preferensi lokal 
Image Picker : Pemilihan foto profil 
Path Provider : Pengelolaan lokasi penyimpanan file 

---

## REST API

PayTrack menggunakan **Nager.Date Public Holidays API** untuk memperoleh informasi hari libur nasional.

**Informasi API:**

- Nama API: Nager.Date Public Holidays API
- Website: https://date.nager.at/
- Method: `GET`
- Negara: Indonesia
- Country Code: `ID`

**Endpoint:**

https://date.nager.at/api/v3/PublicHolidays/2026/ID


**Penggunaan API:**

1. Aplikasi mengirimkan permintaan HTTP GET ke endpoint Nager.Date.
2. API memberikan respons dalam format JSON.
3. Data JSON diproses menjadi objek model `PublicHoliday`.
4. Data hari libur ditampilkan pada halaman Beranda.

---

##  Backend dan Database

PayTrack menggunakan **Supabase** sebagai layanan backend dan PostgreSQL sebagai sistem basis data.

Fungsi Supabase dalam aplikasi:

- Anonymous Authentication untuk membuat sesi pengguna.
- Menyimpan data tagihan pengguna.
- Menjalankan operasi CRUD (Create, Read, Update, Delete).
- Mengelola akses data menggunakan Row Level Security (RLS).

**Tabel database utama:**

`public.bills`

 `id` : ID tagihan 
 `bill_name` : Nama tagihan 
 `provider_name` : Nama penyedia layanan 
 `amount`: Nominal tagihan 
 `category` : Kategori tagihan 
 `due_date` : Tanggal jatuh tempo 
 `payment_status` : Status pembayaran 
 `paid_at` : Waktu pembayaran 
 `note` : Catatan tambahan 
 `created_at` : Waktu pembuatan data 
 `user_id` : ID pengguna pemilik data 

**Keamanan database:**

PayTrack menggunakan Row Level Security (RLS) dengan kebijakan akses berdasarkan `auth.uid() = user_id` agar pengguna hanya dapat mengakses data miliknya sendiri.

---

## Arsitektur Aplikasi

PayTrack menerapkan arsitektur berlapis dengan pola:

**Provider → Repository → Service → Backend/API**

Setiap lapisan memiliki tanggung jawab sebagai berikut:

Models : Mendefinisikan struktur dan representasi data 
Providers : Mengelola state aplikasi dan menghubungkan UI dengan repository 
Repositories : Menjadi perantara antara provider dan service 
Services : Menangani komunikasi dengan Supabase dan REST API 
Screens : Menampilkan halaman antarmuka aplikasi 
Widgets : Menyediakan komponen antarmuka yang dapat digunakan kembali 
Config : Menyimpan konfigurasi layanan aplikasi 

Arsitektur ini membantu memisahkan logika bisnis, pengelolaan data, dan tampilan antarmuka sehingga kode lebih terorganisasi dan mudah dikembangkan.

---

## Struktur Folder Project

expense_task/
│
├── assets/
│   └── images/
│
├── docs/
│   ├── architectural.md
│   └── screenshot/
│       └── UI&Responsive/
│
├── lib/
│   ├── config/
│   │   └── supabase_config.dart
│   │
│   ├── models/
│   │   ├── bill.dart
│   │   └── public_holiday.dart
│   │
│   ├── providers/
│   │   ├── bill_provider.dart
│   │   └── holiday_provider.dart
│   │
│   ├── repositories/
│   │   ├── bill_repository.dart
│   │   └── holiday_repository.dart
│   │
│   ├── screens/
│   │   ├── about_screen.dart
│   │   ├── add_bill_screen.dart
│   │   ├── bill_detail_screen.dart
│   │   ├── bill_list_screen.dart
│   │   ├── edit_bill_screen.dart
│   │   ├── home_screen.dart
│   │   └── payment_history_screen.dart
│   │
│   ├── services/
│   │   ├── bill_service.dart
│   │   ├── holiday_api_service.dart
│   │   └── supabase_bill_service.dart
│   │
│   ├── widgets/
│   │   ├── bill_card.dart
│   │   ├── loading_error_empty_view.dart
│   │   ├── responsive_layout.dart
│   │   └── summary_card.dart
│   │
│   └── main.dart
│
├── test/
│   ├── navigation_flow_test.dart
│   └── ...
│
├── pubspec.yaml
├── pubspec.lock
└── README.md

---

## Alur Penggunaan Aplikasi

Alur penggunaan PayTrack dimulai ketika pengguna membuka aplikasi dan masuk ke halaman utama (Dashboard). Pengguna dapat melihat ringkasan tagihan, total pembayaran, serta informasi tagihan yang akan jatuh tempo.

Berikut tahapan penggunaan aplikasi PayTrack:

1. **Membuka Dashboard**  
   Pengguna melihat ringkasan informasi tagihan dan daftar tagihan yang akan jatuh tempo.

2. **Mengelola Tagihan**  
   Pengguna membuka halaman Daftar Tagihan untuk melihat, mencari, dan memfilter data tagihan.

3. **Menambahkan Tagihan**  
   Pengguna mengisi informasi tagihan, seperti nama tagihan, penyedia layanan, nominal, kategori, tanggal jatuh tempo, dan catatan tambahan.

4. **Melihat Detail Tagihan**  
   Pengguna memilih salah satu tagihan untuk melihat informasi secara lengkap.

5. **Mengubah atau Menghapus Tagihan**  
   Pengguna dapat memperbarui informasi tagihan atau menghapus data yang sudah tidak diperlukan.

6. **Memperbarui Status Pembayaran**  
   Setelah melakukan pembayaran, pengguna dapat mengubah status tagihan menjadi lunas.

7. **Melihat Riwayat Pembayaran**  
   Pengguna membuka halaman Riwayat Pembayaran untuk melihat daftar tagihan yang telah diselesaikan.

8. **Melihat Informasi Aplikasi**  
   Pengguna dapat membuka halaman Tentang Aplikasi untuk mengetahui informasi mengenai PayTrack dan pengembangnya.

Seluruh data tagihan dikelola melalui Supabase, sedangkan informasi hari libur nasional diperoleh melalui REST API Nager.Date.

---

### Diagram Alur Penggunaan

          MULAI
            |
            v
       Buka PayTrack
            |
            v
         Dashboard
            |
            v
      Daftar Tagihan
            |
            v
     Pilih Pengelolaan
            |
      +-----+------+
      |     |      |
      v     v      v
   Tambah  Edit  Hapus
   Tagihan Tagihan Tagihan
      |     |      |
      +-----+------+
            |
            v
      Detail Tagihan
            |
            v
    Perbarui Pembayaran
            |
            v
    Riwayat Pembayaran
            |
            v
          Selesai

---

## Screenshot Aplikasi

Dokumentasi tampilan PayTrack disimpan pada direktori:
```text
docs/screenshot/UI & Responsive
```
Screenshot yang didokumentasikan meliputi tampilan aplikasi pada berbagai ukuran layar.

### Dashboard
![Dashboard PayTrack](<docs/screenshot/UI & Responsive/Dashboard - Mobile.png>)

### Daftar Tagihan
![Daftar Tagihan](<docs/screenshot/UI & Responsive/Halaman Daftar Tagihan - Mobile.png>)

### Tampilan Desktop
![Dashnoard Dekstop](<docs/screenshot/UI & Responsive/Dashboard - Dekstop.png>)

### Tampilan Profil
![Profil](<docs/screenshot/UI & Responsive/Halaman Profil - Desktop.png>)

---

## Cara Menjalankan Project

### 1. Persyaratan

Pastikan perangkat sudah memiliki:

- Flutter SDK
- Dart SDK
- Visual Studio Code atau IDE Flutter lainnya
- Git
- Koneksi internet

### 2. Clone Repository

```bash
git clone https://github.com/Dedz2204/UTS_2415051104_Putu-Agus-Dedy-Putra-Adnyana.git
```

### 3. Masuk ke Direktori Project

```bash
cd UTS_2415051104_Putu-Agus-Dedy-Putra-Adnyana
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Konfigurasi Supabase

Pastikan konfigurasi Supabase sudah disiapkan pada file konfigurasi aplikasi.

Konfigurasi yang diperlukan meliputi:

- Supabase Project URL
- Supabase publishable/anon key
- Tabel `bills`
- Konfigurasi Row Level Security (RLS)
- Anonymous Authentication

Jangan memasukkan secret key atau service role key ke repository publik.

### 6. Jalankan Aplikasi

Untuk menjalankan aplikasi pada perangkat yang tersedia:

```bash
flutter run
```

Untuk menjalankan melalui Google Chrome:

```bash
flutter run -d chrome
```

---

## Pengujian Aplikasi

PayTrack menggunakan Flutter Analyze dan Flutter Test untuk membantu memeriksa kualitas kode dan fungsionalitas aplikasi.

**Menjalankan analisis kode:**

```bash
flutter analyze
```

**Menjalankan seluruh pengujian:**

```bash
flutter test
```
---

## Informasi Project

PayTrack merupakan project Ujian Tengah Semester (UTS) yang dikembangkan untuk menerapkan konsep pengembangan aplikasi menggunakan Flutter, pengelolaan state, integrasi REST API, pengelolaan database Supabase, arsitektur berlapis, serta desain antarmuka responsif.
