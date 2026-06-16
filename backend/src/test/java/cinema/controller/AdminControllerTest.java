package cinema.controller;

import cinema.model.Movie;
import cinema.model.Schedule;
import cinema.repository.MovieRepository;
import cinema.repository.ScheduleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.ResponseEntity;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class AdminControllerTest {

    @Mock
    private MovieRepository movieRepository;

    @Mock
    private ScheduleRepository scheduleRepository;

    @InjectMocks
    private AdminController adminController;

    @BeforeEach
    public void setup() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    public void testCreateScheduleMovieIdRequired() {
        Schedule schedule = new Schedule();
        schedule.setMovie(null); // No movie provided

        ResponseEntity<?> response = adminController.createSchedule(schedule);
        assertEquals(400, response.getStatusCode().value());
        assertEquals("Movie ID is required", response.getBody());
    }

    @Test
    public void testCreateScheduleMovieNotFound() {
        Schedule schedule = new Schedule();
        Movie mockMovie = new Movie();
        mockMovie.setId(99);
        schedule.setMovie(mockMovie);

        // Mock repository to return empty Optional (movie not found)
        when(movieRepository.findById(99)).thenReturn(Optional.empty());

        ResponseEntity<?> response = adminController.createSchedule(schedule);
        assertEquals(400, response.getStatusCode().value());
        assertEquals("Movie not found", response.getBody());
    }

    @Test
    public void testCreateScheduleTimeFormatInvalid() {
        Schedule schedule = new Schedule();
        Movie mockMovie = new Movie();
        mockMovie.setId(1);
        schedule.setMovie(mockMovie);
        schedule.setTime("invalid-time"); // Invalid time format

        when(movieRepository.findById(1)).thenReturn(Optional.of(mockMovie));

        ResponseEntity<?> response = adminController.createSchedule(schedule);
        assertEquals(400, response.getStatusCode().value());
        assertEquals("Format waktu tidak valid.", response.getBody());
    }

    @Test
    public void testCreateScheduleConflictExactDuplicate() {
        Movie mockMovie = new Movie();
        mockMovie.setId(1);
        mockMovie.setDuration(120);

        Schedule newSchedule = new Schedule();
        newSchedule.setMovie(mockMovie);
        newSchedule.setDate("2026-06-16");
        newSchedule.setTime("10:00:00");
        newSchedule.setHall("Studio 1");

        Schedule existingSchedule = new Schedule();
        existingSchedule.setScheduleId(1); // Give it a non-zero ID so it's not filtered out
        existingSchedule.setMovie(mockMovie);
        existingSchedule.setDate("2026-06-16");
        existingSchedule.setTime("10:00:00");
        existingSchedule.setEndTime("12:15:00");
        existingSchedule.setHall("Studio 1");

        List<Schedule> existingList = new ArrayList<>();
        existingList.add(existingSchedule);

        when(movieRepository.findById(1)).thenReturn(Optional.of(mockMovie));
        when(scheduleRepository.findAll()).thenReturn(existingList);
        when(scheduleRepository.save(any(Schedule.class))).thenAnswer(i -> i.getArgument(0));

        ResponseEntity<?> response = adminController.createSchedule(newSchedule);
        assertEquals(400, response.getStatusCode().value());
        assertTrue(response.getBody().toString().contains("Studio Studio 1 sudah memiliki jadwal pada jam 10:00:00"));
    }
}
