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

    @Autowired
    private cinema.repository.SeatRepository seatRepository;

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

        // Otomatis generate 10 kursi untuk jadwal ini
        java.util.List<cinema.model.Seat> seats = new java.util.ArrayList<>();
        for (int i = 1; i <= 10; i++) {
            cinema.model.Seat seat = new cinema.model.Seat();
            seat.setSeatNumber("A" + i);
            seat.setBooked(false);
            seat.setSchedule(saved);
            seats.add(seat);
        }
        seatRepository.saveAll(seats);

        return ResponseEntity.ok(saved);
    }

    @GetMapping("/{id}/seats")
    public ResponseEntity<?> getSeatsBySchedule(@PathVariable int id) {
        return scheduleRepository.findById(id)
                .map(schedule -> ResponseEntity.ok(schedule.getSeats()))
                .orElse(ResponseEntity.notFound().build());
    }

}
