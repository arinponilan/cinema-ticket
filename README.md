# 🎬 TIXTIX PREMIERE - Cinema Ticket Booking System

Sistem Pemesanan Tiket Bioskop untuk Tugas Besar Pemrograman Berorientasi Objek (PBO).

---

## 🏗️ Arsitektur Aplikasi

Proyek ini terbagi menjadi dua bagian utama: **Backend** dan **Frontend**.

### 1. 🖥️ BACKEND (Server Side)
Bagian ini berfungsi sebagai "otak" aplikasi yang mengelola data, database, dan logika bisnis.
*   **Lokasi Folder**: `src/main/java/cinema`
*   **Teknologi**: Java & Spring Boot
*   **Database**: MySQL
*   **Tugas**: 
    *   Menyediakan API untuk Login & Registrasi.
    *   Mengelola data Film, Jadwal, dan Kursi.
    *   Menangani proses transaksi pemesanan tiket.

### 2. 📱 FRONTEND (Client Side / UI)
Bagian ini adalah tampilan aplikasi yang digunakan oleh pengguna di handphone atau laptop.
*   **Lokasi Folder**: `cinema_mobile`
*   **Teknologi**: Dart & Flutter
*   **Tugas**:
    *   Menampilkan antarmuka pengguna (Dashboard film, pemilihan kursi).
    *   Mengambil data dari Backend melalui REST API.
    *   Navigasi antar halaman (Search, Tickets, Profile).

---

## 📁 Struktur Folder Utama

| Nama Folder / File | Jenis | Keterangan |
| :--- | :--- | :--- |
| **`cinema_mobile/`** | **FRONTEND** | Source code aplikasi mobile (Flutter) |
| **`src/`** | **BACKEND** | Source code server (Java Spring Boot) |
| `pom.xml` | Backend | File konfigurasi dependencies Maven |
| `cinema_db.sql` | Database | File SQL untuk mengimpor struktur database MySQL |
| `mvnw` | Backend | Maven Wrapper untuk menjalankan server |

---

## 🚀 Cara Menjalankan Aplikasi

### Menjalankan Backend:
1. Pastikan database MySQL sudah menyala.
2. Jalankan perintah di terminal root:
   ```bash
   mvn spring-boot:run
   ```

### Menjalankan Frontend:
1. Masuk ke folder mobile:
   ```bash
   cd cinema_mobile
   ```
2. Jalankan aplikasi:
   ```bash
   flutter run
   ```

---

## 👥 Tim Pengembang (Kelompok 4 - IF-48-04)

- **Shakira Bilqis Sarwahita** (103012400266)
- **Irzi Arinta Ponilan** (103012400028)
- **Siti Alqia Tonggiroh** (103012400331)
- **Tianisa Sianipar** (103012400213)
- **Naila Amalia** (103012400295)
- **Nadine Nafeesa Setyawan** (103012400133)
