package cinema.model;

import jakarta.persistence.*;
import java.util.List;
import java.util.ArrayList;

@Entity
@DiscriminatorValue("ADMIN")
public class Admin extends User {
    @Transient
    private List<Movie> managedMovies = new ArrayList<>();

    @Transient
    private List<Schedule> managedSchedules = new ArrayList<>();

    @Transient
    private List<Transaction> transactionHistory = new ArrayList<>();

    public Admin() {}

    public Admin(String name, String email, String password) {
        super(name, email, password);
    }

    @Override
    public String getRole() {
        return "Admin";
    }

    // Diagram Methods
    public void addMovie(Movie movie) {
        managedMovies.add(movie);
    }

    public void updateMovie(Movie movie) {
        for (int i = 0; i < managedMovies.size(); i++) {
            if (managedMovies.get(i).getId() == movie.getId()) {
                managedMovies.set(i, movie);
                return;
            }
        }
        managedMovies.add(movie);
    }

    public void deleteMovie(String id) {
        managedMovies.removeIf(movie -> String.valueOf(movie.getId()).equals(id));
    }

    public void addSchedule(Schedule schedule) {
        managedSchedules.add(schedule);
    }

    public void updateSchedule(Schedule schedule) {
        for (int i = 0; i < managedSchedules.size(); i++) {
            if (managedSchedules.get(i).getScheduleId() == schedule.getScheduleId()) {
                managedSchedules.set(i, schedule);
                return;
            }
        }
        managedSchedules.add(schedule);
    }

    public List<Transaction> viewAllTransactions() {
        return transactionHistory;
    }

    public List<Movie> getManagedMovies() { return managedMovies; }
    public void setManagedMovies(List<Movie> managedMovies) { this.managedMovies = managedMovies; }

    public List<Schedule> getManagedSchedules() { return managedSchedules; }
    public void setManagedSchedules(List<Schedule> managedSchedules) { this.managedSchedules = managedSchedules; }

    public List<Transaction> getTransactionHistory() { return transactionHistory; }
    public void setTransactionHistory(List<Transaction> transactionHistory) { this.transactionHistory = transactionHistory; }
}
