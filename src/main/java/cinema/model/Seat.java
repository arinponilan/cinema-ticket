package cinema.model;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "seats")
public class Seat {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String seatNumber;
    private boolean isBooked = false;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "schedule_id")
    private Schedule schedule;

    public Seat() {}

    public Seat(String seatNumber, Schedule schedule) {
        this.seatNumber = seatNumber;
        this.schedule = schedule;
    }

    public void bookSeat() {
        this.isBooked = true;
    }

    public void cancelSeat() {
        this.isBooked = false;
    }

    public boolean isAvailable() {
        return !isBooked;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getSeatNumber() { return seatNumber; }
    public void setSeatNumber(String seatNumber) { this.seatNumber = seatNumber; }

    public boolean isBooked() { return isBooked; }
    public void setBooked(boolean booked) { isBooked = booked; }

    public Schedule getSchedule() { return schedule; }
    public void setSchedule(Schedule schedule) { this.schedule = schedule; }
}

