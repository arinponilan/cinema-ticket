package cinema.model;

import jakarta.persistence.*;
import java.util.List;
import java.util.ArrayList;

@Entity
@DiscriminatorValue("ADMIN")
public class Admin extends User {

    public Admin() {}

    public Admin(String name, String email, String password) {
        super(name, email, password);
    }

    @Override
    public String getRole() {
        return "Admin";
    }

    // Diagram Methods
    public void addMovie(Movie movie) {}
    public void updateMovie(Movie movie) {}
    public void deleteMovie(String id) {}
    public void addSchedule(Schedule schedule) {}
    public void updateSchedule(Schedule schedule) {}
    public List<Transaction> viewAllTransactions() { return new ArrayList<>(); }
}
