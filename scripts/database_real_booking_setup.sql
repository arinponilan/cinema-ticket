START TRANSACTION;

-- Movie di class diagram tidak punya rating.
-- Jalankan ini kalau kolom rating masih ada dari dump lama.
ALTER TABLE movies DROP COLUMN IF EXISTS rating;

-- Service backend membuat 1 ticket per seat dalam 1 booking.
-- Jadi booking_id di tickets tidak boleh UNIQUE.
-- Tambahkan index biasa dulu, karena foreign key tickets.booking_id butuh index.
ALTER TABLE tickets ADD INDEX IF NOT EXISTS idx_tickets_booking_id (booking_id);
ALTER TABLE tickets DROP INDEX IF EXISTS UK_lwytoi4sx2v20kyuj6bvqto1y;

-- Cegah 1 seat masuk dua kali untuk booking yang sama.
ALTER TABLE booking_seats
  ADD UNIQUE KEY IF NOT EXISTS uk_booking_seat (booking_id, seat_id);

-- Cegah seat duplicate di schedule yang sama.
ALTER TABLE seats
  ADD UNIQUE KEY IF NOT EXISTS uk_schedule_seat (schedule_id, seat_number);

-- Pastikan 4 movie utama punya 3 schedule.
-- Kalau schedule di dump sudah ada, query ini tidak membuat duplikat.
INSERT INTO schedules (movie_id, time, date)
SELECT m.id, showtimes.time, '2026-05-21'
FROM movies m
JOIN (
  SELECT '12:40:00' AS time, 1 AS movie_id
  UNION ALL SELECT '16:40:00', 1
  UNION ALL SELECT '20:40:00', 1
  UNION ALL SELECT '11:30:00', 2
  UNION ALL SELECT '15:00:00', 2
  UNION ALL SELECT '19:30:00', 2
  UNION ALL SELECT '10:40:00', 3
  UNION ALL SELECT '14:20:00', 3
  UNION ALL SELECT '18:10:00', 3
  UNION ALL SELECT '13:10:00', 4
  UNION ALL SELECT '17:10:00', 4
  UNION ALL SELECT '21:00:00', 4
) showtimes ON showtimes.movie_id = m.id
WHERE NOT EXISTS (
  SELECT 1
  FROM schedules existing
  WHERE existing.movie_id = m.id
    AND existing.time = showtimes.time
    AND existing.date = '2026-05-21'
);

-- Generate kursi A1-H10 untuk setiap schedule.
-- Total: 12 schedule x 80 kursi = 960 rows.
INSERT INTO seats (is_booked, seat_number, schedule_id)
SELECT
  0,
  CONCAT(seat_rows.row_letter, seat_numbers.seat_no),
  schedules.schedule_id
FROM schedules
JOIN (
  SELECT 'A' AS row_letter
  UNION ALL SELECT 'B'
  UNION ALL SELECT 'C'
  UNION ALL SELECT 'D'
  UNION ALL SELECT 'E'
  UNION ALL SELECT 'F'
  UNION ALL SELECT 'G'
  UNION ALL SELECT 'H'
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
WHERE schedules.movie_id IN (1, 2, 3, 4)
AND NOT EXISTS (
  SELECT 1
  FROM seats existing
  WHERE existing.schedule_id = schedules.schedule_id
    AND existing.seat_number = CONCAT(seat_rows.row_letter, seat_numbers.seat_no)
);

COMMIT;

-- Cek hasil schedule dan seats.
SELECT
  movies.id AS movie_id,
  movies.title,
  schedules.schedule_id,
  schedules.date,
  schedules.time,
  COUNT(seats.id) AS total_seats,
  SUM(CASE WHEN seats.is_booked = 1 THEN 1 ELSE 0 END) AS booked_seats
FROM movies
JOIN schedules ON schedules.movie_id = movies.id
LEFT JOIN seats ON seats.schedule_id = schedules.schedule_id
WHERE movies.id IN (1, 2, 3, 4)
GROUP BY movies.id, movies.title, schedules.schedule_id, schedules.date, schedules.time
ORDER BY movies.id, schedules.time;
