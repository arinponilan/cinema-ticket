package cinema.repository;

import cinema.model.Seat;
import cinema.model.Schedule;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SeatRepository extends JpaRepository<Seat, Integer> {
    Seat findByScheduleAndSeatNumber(Schedule schedule, String seatNumber);
    List<Seat> findByScheduleScheduleIdOrderBySeatNumberAsc(int scheduleId);
}
