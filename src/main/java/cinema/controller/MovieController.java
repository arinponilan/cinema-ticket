package cinema.controller;

import cinema.model.Movie;
import cinema.repository.MovieRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/movies")
@CrossOrigin(origins = "*")
public class MovieController {

    @Autowired
    private MovieRepository movieRepository;

    @GetMapping
    public List<Movie> getAllMovies() {
        return movieRepository.findAll();
    }

    @GetMapping("/search")
    public List<Movie> searchMovies(@RequestParam String q) {
        return movieRepository.findByTitleContainingIgnoreCase(q);
    }

    @PostMapping
    public ResponseEntity<?> addMovie(@RequestBody Movie movie) {
        Movie saved = movieRepository.save(movie);
        return ResponseEntity.ok(saved);
    }
}
