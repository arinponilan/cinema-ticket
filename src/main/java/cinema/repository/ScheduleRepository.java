package cinema.repository;

import cinema.model.Schedule;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Integer> {
    List<Schedule> findByMovieIdOrderByDateAscTimeAsc(int movieId);
}
