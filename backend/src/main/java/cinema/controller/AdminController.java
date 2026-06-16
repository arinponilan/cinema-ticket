package cinema.controller;

import cinema.model.Movie;
import cinema.model.Schedule;
import cinema.model.Seat;
import cinema.repository.MovieRepository;
import cinema.repository.ScheduleRepository;
import cinema.repository.SeatRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    @Autowired
    private MovieRepository movieRepository;

    @Autowired
    private ScheduleRepository scheduleRepository;

    @Autowired
    private SeatRepository seatRepository;

    @PersistenceContext
    private EntityManager entityManager;

    @GetMapping("/movies")
    public List<Movie> getMovies() {
        return movieRepository.findAll();
    }

    @PostMapping("/movies")
    public ResponseEntity<?> createMovie(@RequestBody Movie movie) {
        if (movie.getStatus() == null || movie.getStatus().isBlank()) {
            movie.setStatus("Now Showing");
        }
        return ResponseEntity.ok(movieRepository.save(movie));
    }

    @PutMapping("/movies/{id}")
    public ResponseEntity<?> updateMovie(@PathVariable int id, @RequestBody Movie payload) {
        return movieRepository.findById(id)
                .map(movie -> {
                    movie.setTitle(payload.getTitle());
                    movie.setCode(payload.getCode());
                    movie.setGenre(payload.getGenre());
                    movie.setDuration(payload.getDuration());
                    movie.setSynopsis(payload.getSynopsis());
                    movie.setPrice(payload.getPrice());
                    movie.setImageUrl(payload.getImageUrl());
                    movie.setStatus(payload.getStatus() == null || payload.getStatus().isBlank() ? movie.getStatus() : payload.getStatus());
                    return ResponseEntity.ok(movieRepository.save(movie));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/movies/{id}")
    @Transactional
    public ResponseEntity<?> deleteMovie(@PathVariable int id) {
        if (!movieRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }

        entityManager.createNativeQuery("""
                DELETE FROM transactions
                WHERE booking_id IN (
                    SELECT b.id
                    FROM bookings b
                    JOIN schedules s ON s.schedule_id = b.schedule_id
                    WHERE s.movie_id = :movieId
                )
                """)
                .setParameter("movieId", id)
                .executeUpdate();

        entityManager.createNativeQuery("""
                DELETE FROM tickets
                WHERE booking_id IN (
                    SELECT b.id
                    FROM bookings b
                    JOIN schedules s ON s.schedule_id = b.schedule_id
                    WHERE s.movie_id = :movieId
                )
                OR seat_id IN (
                    SELECT seats.id
                    FROM seats
                    JOIN schedules s ON s.schedule_id = seats.schedule_id
                    WHERE s.movie_id = :movieId
                )
                """)
                .setParameter("movieId", id)
                .executeUpdate();

        entityManager.createNativeQuery("""
                DELETE FROM booking_seats
                WHERE booking_id IN (
                    SELECT b.id
                    FROM bookings b
                    JOIN schedules s ON s.schedule_id = b.schedule_id
                    WHERE s.movie_id = :movieId
                )
                OR seat_id IN (
                    SELECT seats.id
                    FROM seats
                    JOIN schedules s ON s.schedule_id = seats.schedule_id
                    WHERE s.movie_id = :movieId
                )
                """)
                .setParameter("movieId", id)
                .executeUpdate();

        entityManager.createNativeQuery("""
                DELETE FROM bookings
                WHERE schedule_id IN (
                    SELECT schedule_id
                    FROM schedules
                    WHERE movie_id = :movieId
                )
                """)
                .setParameter("movieId", id)
                .executeUpdate();

        entityManager.createNativeQuery("""
                DELETE FROM seats
                WHERE schedule_id IN (
                    SELECT schedule_id
                    FROM schedules
                    WHERE movie_id = :movieId
                )
                """)
                .setParameter("movieId", id)
                .executeUpdate();

        entityManager.createNativeQuery("DELETE FROM schedules WHERE movie_id = :movieId")
                .setParameter("movieId", id)
                .executeUpdate();

        movieRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Movie deleted"));
    }

    @GetMapping("/schedules")
    public List<Schedule> getSchedules() {
        return scheduleRepository.findAll();
    }

    @Autowired
    private cinema.repository.BookingRepository bookingRepository;

    @PostMapping("/schedules")
    public ResponseEntity<?> createSchedule(@RequestBody Schedule schedule) {
        return saveOrUpdateScheduleAdmin(schedule, 0);
    }

    @PutMapping("/schedules/{id}")
    public ResponseEntity<?> updateSchedule(@PathVariable int id, @RequestBody Schedule payload) {
        return saveOrUpdateScheduleAdmin(payload, id);
    }

    private ResponseEntity<?> saveOrUpdateScheduleAdmin(Schedule schedule, int scheduleId) {
        if (schedule.getMovie() == null || schedule.getMovie().getId() <= 0) {
            return ResponseEntity.badRequest().body("Movie ID is required");
        }
        Movie movie = movieRepository.findById(schedule.getMovie().getId()).orElse(null);
        if (movie == null) {
            return ResponseEntity.badRequest().body("Movie not found");
        }

        try {
            String timeStr = schedule.getTime();
            if (timeStr.length() == 5) {
                timeStr += ":00";
                schedule.setTime(timeStr);
            }
            java.time.LocalTime startTime = java.time.LocalTime.parse(timeStr);
            int totalMins = movie.getDuration() + 15;
            java.time.LocalTime endTime = startTime.plusMinutes(totalMins);
            schedule.setEndTime(endTime.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm:ss")));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Format waktu tidak valid.");
        }

        List<Schedule> sameDateSchedules = scheduleRepository.findAll().stream()
                .filter(s -> schedule.getDate().equals(s.getDate()) && s.getScheduleId() != scheduleId)
                .toList();

        java.time.LocalTime newStart = java.time.LocalTime.parse(schedule.getTime());
        java.time.LocalTime newEnd = java.time.LocalTime.parse(schedule.getEndTime());

        for (Schedule existing : sameDateSchedules) {
            // Exact duplicate: same hall + same time
            if (schedule.getHall() != null && schedule.getHall().equals(existing.getHall())
                && schedule.getTime() != null && schedule.getTime().equals(existing.getTime())) {
                return ResponseEntity.badRequest().body("Studio " + schedule.getHall() + " sudah memiliki jadwal pada jam " + schedule.getTime() + " (" + existing.getMovie().getTitle() + ").");
            }

            if (existing.getEndTime() == null || existing.getTime() == null) continue;
            
            try {
                java.time.LocalTime exStart = java.time.LocalTime.parse(existing.getTime());
                java.time.LocalTime exEnd = java.time.LocalTime.parse(existing.getEndTime());

                boolean overlaps = newStart.isBefore(exEnd) && newEnd.isAfter(exStart);

                if (overlaps) {
                    if (schedule.getHall() != null && schedule.getHall().equals(existing.getHall())) {
                        return ResponseEntity.badRequest().body("Studio " + schedule.getHall() + " sudah memiliki jadwal pada jam tersebut (" + existing.getMovie().getTitle() + ").");
                    }
                }
            } catch (Exception ignored) {}
        }

        schedule.setMovie(movie);
        if (scheduleId > 0) {
            Schedule existingRecord = scheduleRepository.findById(scheduleId).orElse(null);
            if (existingRecord != null) {
                existingRecord.setDate(schedule.getDate());
                existingRecord.setTime(schedule.getTime());
                existingRecord.setEndTime(schedule.getEndTime());
                existingRecord.setHall(schedule.getHall());
                if (schedule.getMovie() != null) {
                    existingRecord.setMovie(schedule.getMovie());
                }
                Schedule saved = scheduleRepository.save(existingRecord);
                ensureSeats(saved);
                return ResponseEntity.ok(saved);
            } else {
                return ResponseEntity.notFound().build();
            }
        } else {
            Schedule saved = scheduleRepository.save(schedule);
            ensureSeats(saved);
            return ResponseEntity.ok(saved);
        }
    }

    @DeleteMapping("/schedules/{id}")
    @Transactional
    public ResponseEntity<?> deleteSchedule(@PathVariable int id) {
        if (!scheduleRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        if (bookingRepository.existsBySchedule_ScheduleId(id)) {
            return ResponseEntity.badRequest().body("Jadwal tidak bisa dihapus karena sudah memiliki pemesanan aktif.");
        }
        
        entityManager.createNativeQuery("DELETE FROM seats WHERE schedule_id = :scheduleId")
                .setParameter("scheduleId", id)
                .executeUpdate();

        scheduleRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/reset-database")
    @jakarta.transaction.Transactional
    public ResponseEntity<?> resetDatabase() {
        entityManager.createNativeQuery("TRUNCATE TABLE booking_seats, bookings, seats, schedules, movies CASCADE").executeUpdate();
        return ResponseEntity.ok("Database reset successfully");
    }

    @GetMapping("/seats/{scheduleId}")
    public List<Seat> getSeats(@PathVariable int scheduleId) {
        return seatRepository.findByScheduleScheduleIdOrderBySeatNumberAsc(scheduleId);
    }

    @PutMapping("/seats/{seatId}")
    public ResponseEntity<?> updateSeat(@PathVariable int seatId, @RequestBody Seat payload) {
        return seatRepository.findById(seatId)
                .map(seat -> {
                    seat.setBooked(payload.isBooked());
                    seat.setSeatNumber(payload.getSeatNumber());
                    return ResponseEntity.ok(seatRepository.save(seat));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    private void ensureSeats(Schedule schedule) {
        List<Seat> seats = seatRepository.findByScheduleScheduleIdOrderBySeatNumberAsc(schedule.getScheduleId());
        if (!seats.isEmpty()) {
            return;
        }
        List<Seat> generated = new ArrayList<>();
        
        char endRow = 'J'; // 10 rows (A to J) * 10 columns = 100 seats
        for (char row = 'A'; row <= endRow; row++) {
            for (int col = 1; col <= 10; col++) {
                generated.add(new Seat(row + String.valueOf(col), schedule));
            }
        }
        seatRepository.saveAll(generated);
    }
}
