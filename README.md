# 🎬 Cinema Ticket Booking System

## Sistem pemesanan tiket bioskop berbasis mobile dan backend REST API menggunakan Flutter, Spring Boot, dan PostgreSQL/Supabase.

# 👥 Anggota Kelompok

- Irzi Arinta Ponilan (103012400028)
- Nadine Nafeesa Setyawan (103012400133)
- Tianisa Sianipar (103012400213)
- Shakira Bilqis Sarwahita (103012400266)
- Naila Amalia (103012400295)
- Siti Alqia Tonggiroh (103012400331)

# 🎬 Cinema Ticket Booking System

Aplikasi pemesanan tiket bioskop berbasis mobile menggunakan Flutter, Spring Boot, dan PostgreSQL/Supabase.

---

# 🛠️ Teknologi yang Digunakan

## Backend

- Java Spring Boot
- Maven
- REST API
- Spring Data JPA

## Frontend

- Flutter
- Dart

## Database

- PostgreSQL
- Supabase

---

# ⚙️ Langkah-Langkah Konfigurasi

## 1. Clone Repository

Clone repository GitHub:

```bash
git clone https://github.com/arinponilan/cinema-ticket.git
```

Masuk ke folder project:

```bash
cd cinema-ticket
```

---

# 2. Install Dependencies

Pastikan perangkat sudah terinstall:

- Java JDK 17
- Maven
- Flutter SDK
- PostgreSQL atau Supabase
- Git

Cek versi Java:

```bash
java -version
```

Cek versi Maven:

```bash
mvn -version
```

Cek Flutter:

```bash
flutter doctor
```

---

# 3. Buat Database PostgreSQL/Supabase

Buat database PostgreSQL lokal atau gunakan project Supabase.

```sql
CREATE DATABASE cinema_db;
```

---

# 4. Konfigurasi Database Spring Boot

Buat file `.env` lokal dari contoh yang sudah disediakan:

```bash
cd backend
cp .env.example .env
```

Lalu isi nilai koneksi database di `backend/.env`:

```properties
DATABASE_URL=jdbc:postgresql://localhost:5432/cinema_db
DB_USERNAME=nama_user_postgres_lokal
DB_PASSWORD=password_postgres_lokal
```

Catatan untuk macOS/Homebrew PostgreSQL: user lokal sering sama dengan username macOS, misalnya `kia`, bukan `postgres`. Jika muncul error `FATAL: role "postgres" does not exist`, ganti `DB_USERNAME` di `backend/.env` ke user PostgreSQL yang tersedia.

Jika menggunakan Supabase pooler, isi `.env` seperti ini:

```properties
DATABASE_URL=jdbc:postgresql://aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres?sslmode=require
DB_USERNAME=postgres.PROJECT_REF
DB_PASSWORD=PASSWORD_SUPABASE
```

Spring Boot akan membaca `backend/.env` otomatis saat backend dijalankan dari folder `backend`, jadi tidak perlu menjalankan `source .env`.

Konfigurasi fallback tetap tersedia di:

```text
backend/src/main/resources/application.properties
```

---

# 5. Jalankan Backend Spring Boot

Jalankan backend menggunakan command:

```bash
cd backend
./mvnw spring-boot:run
```

Jika berhasil, backend berjalan di:

```text
http://localhost:8081
```

---

# 6. Jalankan Flutter

Masuk ke folder Flutter:

```bash
cd cinema_mobile
```

Install dependency Flutter:

```bash
flutter pub get
```

Jalankan aplikasi:

```bash
flutter run
```

---

# 7. Konfigurasi Backend Flutter

Pastikan URL backend pada Flutter mengarah ke backend Spring Boot.

Contoh untuk Android Emulator:

```dart
const String backendBaseUrl = 'http://10.0.2.2:8081';
```

---

# 8. Import Data Awal Database

Import data:

- movies
- schedules
- seats

menggunakan file SQL sample atau query INSERT yang telah disediakan.

---

# 📌 Struktur Database

Database menggunakan tabel utama:

- users
- movies
- schedules
- seats
- bookings
- booking_seats

---

# 🎟️ Sistem Booking

Setiap:

- movie
- schedule

memiliki data seat masing-masing.

Seat disimpan berdasarkan:

```text
schedule_id
```

---

# 🚀 Menjalankan Project

## Backend

```bash
mvn spring-boot:run
```

## Frontend Flutter

```bash
flutter run
```

---

# 📄 Repository

`https://github.com/arinponilan/cinema-ticket.git`
