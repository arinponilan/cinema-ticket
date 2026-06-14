package cinema.controller;

import cinema.model.Movie;
import cinema.repository.MovieRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/movies")
@CrossOrigin(origins = "*")
public class MovieController {

    @Autowired
    private MovieRepository movieRepository;

    private static final Map<String, String> DEFAULT_IMAGE_URLS = Map.of(
        "Avengers: Endgame", "https://upload.wikimedia.org/wikipedia/en/0/0d/Avengers_Endgame_poster.jpg",
        "Spider-Man: No Way Home", "https://upload.wikimedia.org/wikipedia/en/0/00/Spider-Man_No_Way_Home_poster.jpg",
        "Batman: The Dark Knight", "https://upload.wikimedia.org/wikipedia/en/1/1c/The_Dark_Knight_%282008_film%29.jpg",
        "John Wick 4", "https://upload.wikimedia.org/wikipedia/en/d/d0/John_Wick_-_Chapter_4_promotional_poster.jpg"
    );

    @GetMapping
    public List<Movie> getAllMovies() {
        List<Movie> movies = movieRepository.findAll();
        movies.forEach(this::applyDefaultImage);
        return movies;
    }

    @PostMapping
    public ResponseEntity<?> addMovie(@RequestBody Movie movie) {
        applyDefaultImage(movie);
        Movie saved = movieRepository.save(movie);
        return ResponseEntity.ok(saved);
    }

    private void applyDefaultImage(Movie movie) {
        if (movie.getImageUrl() == null || movie.getImageUrl().isBlank()) {
            String fallback = DEFAULT_IMAGE_URLS.get(movie.getTitle());
            if (fallback != null) {
                movie.setImageUrl(fallback);
            } else {
                movie.setImageUrl("https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=700&q=80");
            }
        }
    }

    @GetMapping("/fix-images")
    public ResponseEntity<?> fixImages() {
        List<Movie> movies = movieRepository.findAll();
        int updated = 0;
        for (Movie movie : movies) {
            String encodedTitle = movie.getTitle().replace(" ", "+");
            String newUrl = "https://placehold.co/600x900/1a1a1a/FFFFFF/png?text=" + encodedTitle;
            movie.setImageUrl(newUrl);
            movieRepository.save(movie);
            updated++;
        }
        return ResponseEntity.ok("Fixed " + updated + " movies with placehold.co images");
    }
}
