package cinema.repository;

import cinema.model.NotificationItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<NotificationItem, Integer> {
    List<NotificationItem> findAllByOrderByCreatedAtDesc();
}
