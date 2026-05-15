package cinema.repository;

import cinema.model.Movie;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MovieRepository extends JpaRepository<Movie, Integer> {
    List<Movie> findByIdInOrderByIdAsc(List<Integer> ids);
}
