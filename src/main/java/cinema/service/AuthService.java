package cinema.service;

import cinema.model.*;
import cinema.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Optional;
import java.util.List;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    private List<User> users; // From Diagram

    public User login(String email, String password) {
        Optional<User> user = userRepository.findByEmail(email);
        if (user.isPresent() && user.get().getPassword().equals(password)) {
            return user.get();
        }
        return null;
    }

    public User register(String name, String email, String password, boolean isAdmin) {
        if (userRepository.findByEmail(email).isPresent()) {
            throw new RuntimeException("Email sudah terdaftar");
        }
        User newUser = isAdmin ? new Admin(name, email, password) : new Customer(name, email, password);
        return userRepository.save(newUser);
    }

    public void logout(User user) {
        // Implementation for logout
    }

    public void changePassword(User user, String newPass) {
        user.setPassword(newPass);
        userRepository.save(user);
    }
}

