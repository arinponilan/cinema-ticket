package cinema.model;

import jakarta.persistence.*;
import java.util.List;
import java.util.ArrayList;
import java.util.Objects;
import java.util.stream.Collectors;

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

    public Booking createBooking(Schedule schedule, List<Seat> seats) {
        Booking booking = new Booking();
        booking.setUser(this);
        booking.setSchedule(schedule);
        booking.setSeats(seats);
        booking.setTotalPrice(booking.calculateTotal());
        booking.createBooking();
        bookingHistory.add(booking);
        return booking;
    }

    public boolean cancelBooking(String bookingId) {
        for (Booking booking : bookingHistory) {
            if (Objects.equals(booking.getBookingCode(), bookingId)) {
                booking.cancelBooking();
                return true;
            }
        }
        return false;
    }

    public List<Booking> viewBookingHistory() { return bookingHistory; }

    public List<Booking> getActiveBookings() {
        return bookingHistory.stream()
                .filter(booking -> !"CANCELLED".equalsIgnoreCase(booking.getStatus()))
                .collect(Collectors.toList());
    }

    public boolean updateProfile(String name, String email, String password) {
        setName(name);
        setEmail(email);
        setPassword(password);
        return true;
    }

    // Getters and Setters
    public double getBalance() { return balance; }
    public void setBalance(double balance) { this.balance = balance; }
    public List<Booking> getBookingHistory() { return bookingHistory; }
    public void setBookingHistory(List<Booking> bookingHistory) { this.bookingHistory = bookingHistory; }
}
