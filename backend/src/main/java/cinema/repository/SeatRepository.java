package cinema.repository;

import cinema.model.Seat;
import cinema.model.Schedule;
import java.util.List;
import java.util.Optional;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface SeatRepository extends JpaRepository<Seat, Integer> {
    Seat findByScheduleAndSeatNumber(Schedule schedule, String seatNumber);
    List<Seat> findByScheduleScheduleIdOrderBySeatNumberAsc(int scheduleId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT s FROM Seat s WHERE s.id = :id")
    Optional<Seat> findByIdForUpdate(@Param("id") Integer id);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT s FROM Seat s WHERE s.schedule = :schedule AND s.seatNumber = :seatNumber")
    Seat findByScheduleAndSeatNumberForUpdate(@Param("schedule") Schedule schedule, @Param("seatNumber") String seatNumber);
}
