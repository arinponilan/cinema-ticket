# 🎬 Cinema Ticket Booking System

## Sistem pemesanan tiket bioskop berbasis mobile dan backend REST API menggunakan Flutter, Spring Boot, dan MySQL.

# 👥 Anggota Kelompok

- Irzi Arinta Ponilan (103012400028)
- Nadine Nafeesa Setyawan (103012400133)
- Tianisa Sianipar (103012400213)
- Shakira Bilqis Sarwahita (103012400266)
- Naila Amalia (103012400295)
- Siti Alqia Tonggiroh (103012400331)

# 🎬 Cinema Ticket Booking System

Aplikasi pemesanan tiket bioskop berbasis mobile menggunakan Flutter, Spring Boot, dan MySQL.

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

- MySQL
- phpMyAdmin

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

- Java JDK 21
- Maven
- Flutter SDK
- MySQL
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

# 3. Buat Database MySQL

Buka phpMyAdmin atau MySQL Workbench lalu buat database:

```sql
CREATE DATABASE cinema_db;
```

---

# 4. Konfigurasi Database Spring Boot

Buka file:

```text
src/main/resources/application.properties
```

Pastikan konfigurasi database sesuai:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/cinema_db
spring.datasource.username=root
spring.datasource.password=

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

Jika MySQL menggunakan password, isi pada:

```properties
spring.datasource.password=PASSWORD_MYSQL
```

---

# 5. Jalankan Backend Spring Boot

Jalankan backend menggunakan command:

```bash
mvn spring-boot:run
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

```https://github.com/arinponilan/cinema-ticket.git```
