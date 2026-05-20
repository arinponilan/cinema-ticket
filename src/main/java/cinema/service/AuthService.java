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

    @jakarta.annotation.PostConstruct
    public void initAdmin() {
        if (!userRepository.findByEmail("admin@gmail.com").isPresent()) {
            Admin admin = new Admin("System Admin", "admin@gmail.com", "admin123");
            userRepository.save(admin);
        }
    }

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
        // Paksa jadi Customer untuk registrasi publik
        User newUser = new Customer(name, email, password);
        return userRepository.save(newUser);
    }


    public void logout(User user) {
        // Implementation for logout
    }

    public boolean changePassword(Integer userId, String oldPassword, String newPassword) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.getPassword().equals(oldPassword)) {
                user.setPassword(newPassword);
                userRepository.save(user);
                return true;
            }
        }
        return false;
    }

    public void changePassword(String email, String currentPassword, String newPassword) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User tidak ditemukan"));

        if (!user.getPassword().equals(currentPassword)) {
            throw new RuntimeException("Password lama salah");
        }

        user.setPassword(newPassword);
        userRepository.save(user);
    }
}

