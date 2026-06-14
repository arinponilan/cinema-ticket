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

    @PostMapping("/schedules")
    public ResponseEntity<?> createSchedule(@RequestBody Schedule schedule) {
        if (schedule.getMovie() == null || schedule.getMovie().getId() <= 0) {
            return ResponseEntity.badRequest().body("Movie ID is required");
        }
        Movie movie = movieRepository.findById(schedule.getMovie().getId()).orElse(null);
        if (movie == null) {
            return ResponseEntity.badRequest().body("Movie not found");
        }
        schedule.setMovie(movie);
        Schedule saved = scheduleRepository.save(schedule);
        ensureSeats(saved);
        return ResponseEntity.ok(saved);
    }

    @PutMapping("/schedules/{id}")
    public ResponseEntity<?> updateSchedule(@PathVariable int id, @RequestBody Schedule payload) {
        return scheduleRepository.findById(id)
                .map(schedule -> {
                    if (payload.getMovie() != null && payload.getMovie().getId() > 0) {
                        movieRepository.findById(payload.getMovie().getId()).ifPresent(schedule::setMovie);
                    }
                    schedule.setDate(payload.getDate());
                    schedule.setTime(payload.getTime());
                    schedule.setHall(payload.getHall());
                    Schedule saved = scheduleRepository.save(schedule);
                    ensureSeats(saved);
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/schedules/{id}")
    public ResponseEntity<?> deleteSchedule(@PathVariable int id) {
        scheduleRepository.deleteById(id);
        return ResponseEntity.ok().build();
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
        for (char row = 'A'; row <= 'H'; row++) {
            for (int col = 1; col <= 10; col++) {
                generated.add(new Seat(row + String.valueOf(col), schedule));
            }
        }
        seatRepository.saveAll(generated);
    }
}
