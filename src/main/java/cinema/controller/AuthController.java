package cinema.controller;

import cinema.dto.LoginRequest;
import cinema.dto.RegisterRequest;
import cinema.model.User;
import cinema.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        User user = authService.login(request.getEmail(), request.getPassword());
        if (user != null) {
            return ResponseEntity.ok(user);
        }
        return ResponseEntity.status(401).body("Login gagal! Email atau password salah.");
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        try {
            User user = authService.register(
                request.getName(), 
                request.getEmail(), 
                request.getPassword(), 
                request.isAdmin()
            );
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody cinema.dto.ChangePasswordRequest request) {
        boolean success = authService.changePassword(
            request.getUserId(), 
            request.getOldPassword(), 
            request.getNewPassword()
        );
        if (success) {
            return ResponseEntity.ok("Password berhasil diubah!");
        } else {
            return ResponseEntity.status(400).body("Password lama salah atau user tidak ditemukan.");
        }
    }
}
