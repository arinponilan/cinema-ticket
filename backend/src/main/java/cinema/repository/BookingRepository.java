package cinema.repository;

import cinema.model.Booking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Integer> {
    List<Booking> findByUser_UserId(int userId);
    List<Booking> findByUserUserId(int userId);
    List<Booking> findByUserUserIdOrderByIdDesc(int userId);
    boolean existsBySchedule_ScheduleId(int scheduleId);
}
