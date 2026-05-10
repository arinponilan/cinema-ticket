package cinema.model;

import jakarta.persistence.*;
import java.util.List;
import java.util.ArrayList;

@Entity
@DiscriminatorValue("CUSTOMER")
public class Customer extends User {
    private double balance;
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Booking> bookingHistory = new ArrayList<>();

    public Customer() {}

    public Customer(String name, String email, String password) {
        super(name, email, password);
    }

    @Override
    public String getRole() {
        return "Customer";
    }

    // Diagram Methods
    public List<Movie> viewMovies() { return new ArrayList<>(); }
    public Booking createBooking(Schedule schedule, List<Seat> seats) { return null; }
    public boolean cancelBooking(String bookingId) { return true; }
    public List<Booking> viewBookingHistory() { return bookingHistory; }
    public List<Booking> getActiveBookings() { return new ArrayList<>(); }
    public boolean updateProfile(String name, String email, String password) { return true; }

    // Getters and Setters
    public double getBalance() { return balance; }
    public void setBalance(double balance) { this.balance = balance; }
    public List<Booking> getBookingHistory() { return bookingHistory; }
    public void setBookingHistory(List<Booking> bookingHistory) { this.bookingHistory = bookingHistory; }
}
