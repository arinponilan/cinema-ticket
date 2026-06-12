package cinema.repository;

import cinema.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Integer> {
    Optional<Transaction> findByBooking_Id(int bookingId);
    List<Transaction> findByBookingUserUserIdOrderByTransactionDateDesc(int userId);
}
