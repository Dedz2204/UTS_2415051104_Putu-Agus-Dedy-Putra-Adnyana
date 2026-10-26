# ExpenseTask — Architectural Documentation

## 1. Overview

ExpenseTask merupakan aplikasi untuk membantu pengguna mencatat dan mengelola tagihan, termasuk informasi pembayaran dan pengingat tanggal jatuh tempo. Aplikasi dirancang dengan pemisahan tanggung jawab agar kode lebih terstruktur, mudah dipahami, dan mudah dikembangkan.

## 2. Architecture Pattern

ExpenseTask menggunakan pendekatan berlapis (*layered architecture*) dengan alur sebagai berikut:

**Screen/Widget → Provider → Repository → Service/Data Source → REST API atau Supabase**

Setiap lapisan memiliki tanggung jawab tersendiri. Pemisahan ini bertujuan agar tampilan tidak bergantung langsung pada implementasi akses data.

## 3. Folder Structure

### `lib/models/`

Menyimpan model data yang digunakan aplikasi.

- `bill.dart`: merepresentasikan data tagihan.
- `public_holiday.dart`: merepresentasikan data hari libur dari REST API.

### `lib/services/`

Menangani komunikasi dengan sumber data.

- `bill_service.dart`: mendefinisikan tanggung jawab atau kontrak layanan data tagihan.
- `supabase_bill_service.dart`: menangani operasi data tagihan melalui Supabase.
- `holiday_api_service.dart`: menangani permintaan data hari libur melalui REST API.

### `lib/repositories/`

Menjadi penghubung antara Provider dan Service. Repository mengatur operasi pengambilan dan pengelolaan data sesuai kebutuhan aplikasi.

- `bill_repository.dart`: mengelola akses data tagihan melalui service.
- `holiday_repository.dart`: mengelola akses data hari libur melalui API service.

### `lib/providers/`

Mengelola state aplikasi dan menyediakan data kepada tampilan.

- `bill_provider.dart`: bertanggung jawab atas state dan operasi data tagihan.
- `holiday_provider.dart`: bertanggung jawab atas state data hari libur.

### `lib/screens/`

Menyimpan halaman utama aplikasi.

- `home_screen.dart`: halaman utama dan ringkasan tagihan.
- `bill_list_screen.dart`: daftar tagihan.
- `add_bill_screen.dart`: formulir penambahan tagihan.
- `edit_bill_screen.dart`: formulir perubahan tagihan.
- `bill_detail_screen.dart`: detail tagihan.
- `payment_history_screen.dart`: riwayat pembayaran.
- `about_screen.dart`: informasi aplikasi.

### `lib/widgets/`

Menyimpan komponen UI yang dapat digunakan kembali.

- `bill_card.dart`: kartu informasi tagihan.
- `summary_card.dart`: kartu ringkasan tagihan.
- `loading_error_empty_view.dart`: tampilan loading, error, dan data kosong.
- `responsive_layout.dart`: komponen pendukung tata letak responsif.

### `lib/config/`

Menyimpan konfigurasi aplikasi yang diperlukan untuk mengakses layanan eksternal, seperti konfigurasi Supabase. Informasi rahasia tidak boleh ditanamkan langsung ke dalam kode aplikasi.

## 4. Data Flow

Alur data yang direncanakan pada aplikasi adalah sebagai berikut:

1. Screen menampilkan informasi dan menerima interaksi pengguna.
2. Provider mengelola state serta menjalankan operasi yang dibutuhkan oleh Screen.
3. Repository mengatur akses data melalui service yang sesuai.
4. Service berkomunikasi dengan Supabase atau REST API.
5. Data hasil operasi dikembalikan melalui Repository dan Provider untuk ditampilkan pada Screen.

## 5. Architecture Rules

1. Screen dan Widget berfokus pada tampilan serta interaksi pengguna.
2. Screen tidak melakukan HTTP request secara langsung.
3. Screen tidak menjalankan query database Supabase secara langsung.
4. Provider bertanggung jawab atas pengelolaan state aplikasi.
5. Repository memisahkan kebutuhan data aplikasi dari implementasi sumber data.
6. Service bertanggung jawab atas komunikasi dengan sumber data.
7. Model digunakan untuk merepresentasikan data aplikasi.
8. Komponen UI yang digunakan berulang sebaiknya ditempatkan pada folder `widgets`.

## 6. Implementation Status

Dokumen ini menjelaskan struktur dan rancangan arsitektur ExpenseTask. Keberadaan file dan dokumentasi tidak dengan sendirinya membuktikan bahwa seluruh lapisan telah diimplementasikan atau saling terhubung. Implementasi dan pengujian setiap lapisan dilakukan secara bertahap sesuai tahapan pengerjaan proyek.
