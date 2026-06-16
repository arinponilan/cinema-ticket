package cinema.controller;

import cinema.model.Movie;
import cinema.model.Schedule;
import cinema.repository.BookingRepository;
import cinema.repository.MovieRepository;
import cinema.repository.ScheduleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@RestController
@RequestMapping("/api/schedules")
@CrossOrigin(origins = "*")
public class ScheduleController {

    @Autowired
    private ScheduleRepository scheduleRepository;

    @Autowired
    private MovieRepository movieRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @GetMapping
    public List<Schedule> getAllSchedules() {
        return scheduleRepository.findAll();
    }

    @GetMapping("/movie/{movieId}")
    public List<Schedule> getSchedulesByMovie(@PathVariable int movieId) {
        return scheduleRepository.findByMovie_IdOrderByDateAscTimeAsc(movieId);
    }

    @PostMapping
    public ResponseEntity<?> addSchedule(@RequestBody Schedule schedule) {
        return saveOrUpdateSchedule(schedule, 0);
    }

    @PostMapping("/seed-uniform")
    public ResponseEntity<?> seedUniformSchedules() {
        try {
            bookingRepository.deleteAll();
            scheduleRepository.deleteAll();

            List<Movie> movies = movieRepository.findAll();
            String date = java.time.LocalDate.now().plusDays(1).toString();
            String[] standardTimes = {"10:00:00", "13:00:00", "16:00:00", "19:00:00"};
            
            int studioCounter = 1;
            for (Movie movie : movies) {
                String hall = "Studio " + studioCounter;
                for (String timeStr : standardTimes) {
                    Schedule s = new Schedule(movie, timeStr);
                    s.setDate(date);
                    s.setHall(hall);
                    
                    LocalTime startTime = LocalTime.parse(timeStr);
                    int totalMins = movie.getDuration() + 15;
                    LocalTime endTime = startTime.plusMinutes(totalMins);
                    s.setEndTime(endTime.format(DateTimeFormatter.ofPattern("HH:mm:ss")));
                    
                    scheduleRepository.save(s);
                }
                studioCounter++;
                if (studioCounter > 5) studioCounter = 1;
            }
            return ResponseEntity.ok("Seeded schedules successfully.");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Failed to seed: " + e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateSchedule(@PathVariable int id, @RequestBody Schedule schedule) {
        return saveOrUpdateSchedule(schedule, id);
    }

    private ResponseEntity<?> saveOrUpdateSchedule(Schedule schedule, int scheduleId) {
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
            LocalTime startTime = LocalTime.parse(timeStr);
            int totalMins = movie.getDuration() + 15;
            LocalTime endTime = startTime.plusMinutes(totalMins);
            schedule.setEndTime(endTime.format(DateTimeFormatter.ofPattern("HH:mm:ss")));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Format waktu tidak valid.");
        }

        List<Schedule> sameDateSchedules = scheduleRepository.findAll().stream()
                .filter(s -> schedule.getDate().equals(s.getDate()) && s.getScheduleId() != scheduleId)
                .toList();

        LocalTime newStart = LocalTime.parse(schedule.getTime());
        LocalTime newEnd = LocalTime.parse(schedule.getEndTime());

        for (Schedule existing : sameDateSchedules) {
            if (existing.getEndTime() == null || existing.getTime() == null) continue;
            
            try {
                LocalTime exStart = LocalTime.parse(existing.getTime());
                LocalTime exEnd = LocalTime.parse(existing.getEndTime());

                boolean overlaps = newStart.isBefore(exEnd) && newEnd.isAfter(exStart);

                if (overlaps) {
                    if (schedule.getHall().equals(existing.getHall())) {
                        return ResponseEntity.badRequest().body("Studio " + schedule.getHall() + " sudah memiliki jadwal pada jam tersebut (" + existing.getMovie().getTitle() + ").");
                    }
                    if (existing.getMovie().getId() == movie.getId()) {
                        return ResponseEntity.badRequest().body("Film ini sudah tayang di " + existing.getHall() + " pada waktu yang beririsan.");
                    }
                }
            } catch (Exception ignored) {}
        }

        schedule.setMovie(movie);
        if (scheduleId > 0) {
            schedule.setScheduleId(scheduleId);
            
            Schedule existingRecord = scheduleRepository.findById(scheduleId).orElse(null);
            if (existingRecord != null) {
                schedule.setSeats(existingRecord.getSeats());
            }
        }
        Schedule saved = scheduleRepository.save(schedule);
        return ResponseEntity.ok(saved);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteSchedule(@PathVariable int id) {
        if (!scheduleRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        if (bookingRepository.existsBySchedule_ScheduleId(id)) {
            return ResponseEntity.badRequest().body("Jadwal tidak bisa dihapus karena sudah memiliki pemesanan aktif.");
        }
        scheduleRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}/seats")
    public ResponseEntity<?> getSeatsBySchedule(@PathVariable int id) {
        return scheduleRepository.findById(id)
                .map(schedule -> ResponseEntity.ok(schedule.getSeats()))
                .orElse(ResponseEntity.notFound().build());
    }
}
