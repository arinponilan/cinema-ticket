package cinema.controller;

import cinema.model.Schedule;
import cinema.repository.ScheduleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/schedules")
@CrossOrigin(origins = "*")
public class ScheduleController {

    @Autowired
    private ScheduleRepository scheduleRepository;

    @GetMapping
    public List<Schedule> getAllSchedules() {
        return scheduleRepository.findAll();
    }

    @GetMapping("/movie/{movieId}")
    public List<Schedule> getSchedulesByMovie(@PathVariable int movieId) {
        return scheduleRepository.findByMovieIdOrderByDateAscTimeAsc(movieId);
    }

    @Autowired
    private cinema.repository.MovieRepository movieRepository;

    @PostMapping
    public ResponseEntity<?> addSchedule(@RequestBody Schedule schedule) {
        if (schedule.getMovie() == null || schedule.getMovie().getId() <= 0) {
            return ResponseEntity.badRequest().body("Movie ID is required");
        }
        
        cinema.model.Movie movie = movieRepository.findById(schedule.getMovie().getId()).orElse(null);
        if (movie == null) {
            return ResponseEntity.badRequest().body("Movie not found");
        }
        
        schedule.setMovie(movie);
        Schedule saved = scheduleRepository.save(schedule);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/{id}/seats")
    public ResponseEntity<?> getSeatsBySchedule(@PathVariable int id) {
        return scheduleRepository.findById(id)
                .map(schedule -> ResponseEntity.ok(schedule.getSeats()))
                .orElse(ResponseEntity.notFound().build());
    }

}
