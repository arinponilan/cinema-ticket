SET FOREIGN_KEY_CHECKS = 0;

-- Kosongkan data transaksi/booking dulu karena semuanya bergantung ke seats/schedules.
DELETE FROM transactions;
DELETE FROM tickets;
DELETE FROM booking_seats;
DELETE FROM bookings;
DELETE FROM seats;
DELETE FROM schedules;

-- Reset id supaya rapi mulai dari 1 lagi.
ALTER TABLE transactions AUTO_INCREMENT = 1;
ALTER TABLE tickets AUTO_INCREMENT = 1;
ALTER TABLE bookings AUTO_INCREMENT = 1;
ALTER TABLE seats AUTO_INCREMENT = 1;
ALTER TABLE schedules AUTO_INCREMENT = 1;

SET FOREIGN_KEY_CHECKS = 1;

-- Pastikan struktur tickets bisa menyimpan banyak ticket untuk 1 booking.
-- Kalau index sudah ada, bagian ini aman di MariaDB 10.4+.
ALTER TABLE tickets ADD INDEX IF NOT EXISTS idx_tickets_booking_id (booking_id);
ALTER TABLE tickets DROP INDEX IF EXISTS UK_lwytoi4sx2v20kyuj6bvqto1y;

-- Pastikan tidak ada duplikasi seat.
ALTER TABLE booking_seats
  ADD UNIQUE KEY IF NOT EXISTS uk_booking_seat (booking_id, seat_id);

ALTER TABLE seats
  ADD UNIQUE KEY IF NOT EXISTS uk_schedule_seat (schedule_id, seat_number);

-- Buat ulang schedule id 1-12 untuk 4 movie.
INSERT INTO schedules (schedule_id, time, movie_id, date) VALUES
(1, '12:40:00', 1, '2026-05-21'),
(2, '16:40:00', 1, '2026-05-21'),
(3, '20:40:00', 1, '2026-05-21'),
(4, '11:30:00', 2, '2026-05-21'),
(5, '15:00:00', 2, '2026-05-21'),
(6, '19:30:00', 2, '2026-05-21'),
(7, '10:40:00', 3, '2026-05-21'),
(8, '14:20:00', 3, '2026-05-21'),
(9, '18:10:00', 3, '2026-05-21'),
(10, '13:10:00', 4, '2026-05-21'),
(11, '17:10:00', 4, '2026-05-21'),
(12, '21:00:00', 4, '2026-05-21');

ALTER TABLE schedules AUTO_INCREMENT = 13;

-- Buat ulang seats id mulai dari 1.
-- Urutan id per schedule: A1-A10, B1-B10, ..., H1-H10.
INSERT INTO seats (is_booked, seat_number, schedule_id)
SELECT
  0,
  CONCAT(seat_rows.row_letter, seat_numbers.seat_no),
  schedules.schedule_id
FROM schedules
JOIN (
  SELECT 'A' AS row_letter, 1 AS row_order
  UNION ALL SELECT 'B', 2
  UNION ALL SELECT 'C', 3
  UNION ALL SELECT 'D', 4
  UNION ALL SELECT 'E', 5
  UNION ALL SELECT 'F', 6
  UNION ALL SELECT 'G', 7
  UNION ALL SELECT 'H', 8
) seat_rows
JOIN (
  SELECT 1 AS seat_no
  UNION ALL SELECT 2
  UNION ALL SELECT 3
  UNION ALL SELECT 4
  UNION ALL SELECT 5
  UNION ALL SELECT 6
  UNION ALL SELECT 7
  UNION ALL SELECT 8
  UNION ALL SELECT 9
  UNION ALL SELECT 10
) seat_numbers
ORDER BY schedules.schedule_id, seat_rows.row_order, seat_numbers.seat_no;

ALTER TABLE seats AUTO_INCREMENT = 961;

-- Cek hasil akhir.
SELECT
  movies.id AS movie_id,
  movies.title,
  schedules.schedule_id,
  schedules.date,
  schedules.time,
  MIN(seats.id) AS first_seat_id,
  MAX(seats.id) AS last_seat_id,
  COUNT(seats.id) AS total_seats
FROM movies
JOIN schedules ON schedules.movie_id = movies.id
LEFT JOIN seats ON seats.schedule_id = schedules.schedule_id
GROUP BY movies.id, movies.title, schedules.schedule_id, schedules.date, schedules.time
ORDER BY schedules.schedule_id;
