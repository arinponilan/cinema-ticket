package cinema.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

@Entity
@Table(name = "transactions")
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int transactionId;

    @OneToOne
    @JoinColumn(name = "booking_id")
    private Booking booking;

    private double total;
    private String status;
    private LocalDateTime transactionDate;

    public Transaction() {}

    public void createTransaction() {
        this.transactionDate = LocalDateTime.now();
        this.status = "PENDING";
    }

    public List<Transaction> getTransactionHistory(User user) {
        return new ArrayList<>();
    }

    public void displayTransaction() {
        System.out.println("Transaction ID: " + transactionId + ", Total: " + total + ", Status: " + status);
    }

    public void updateStatus(String status) {
        this.status = status;
    }

    public void addSeat() {}

    public int getTransactionId() { return transactionId; }
    public void setTransactionId(int transactionId) { this.transactionId = transactionId; }

    public Booking getBooking() { return booking; }
    public void setBooking(Booking booking) { this.booking = booking; }

    public double getTotal() { return total; }
    public void setTotal(double total) { this.total = total; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getTransactionDate() { return transactionDate; }
    public void setTransactionDate(LocalDateTime transactionDate) { this.transactionDate = transactionDate; }
}

