package cinema.repository;

import cinema.model.Booking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Integer> {
<<<<<<< HEAD
    List<Booking> findByUser_UserId(int userId);
=======
    List<Booking> findByUserUserId(int userId);
    List<Booking> findByUserUserIdOrderByIdDesc(int userId);
>>>>>>> 3033a92229b4c4e5e34d9bff2d3a12d403efb7ee
}
