package cinema.controller;

import cinema.model.NotificationItem;
import cinema.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {

    @Autowired
    private NotificationRepository notificationRepository;

    @GetMapping
    public List<NotificationItem> getAllNotifications() {
        return notificationRepository.findAllByOrderByCreatedAtDesc();
    }

    @PostMapping
    public ResponseEntity<?> createNotification(@RequestBody NotificationItem notification) {
        notification.setReadStatus(false);
        return ResponseEntity.ok(notificationRepository.save(notification));
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<?> markAsRead(@PathVariable int id) {
        return notificationRepository.findById(id)
                .map(item -> {
                    item.setReadStatus(true);
                    return ResponseEntity.ok(notificationRepository.save(item));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/read-all")
    public ResponseEntity<?> markAllAsRead() {
        List<NotificationItem> items = notificationRepository.findAll();
        items.forEach(item -> item.setReadStatus(true));
        notificationRepository.saveAll(items);
        Map<String, Object> response = new HashMap<>();
        response.put("updated", items.size());
        return ResponseEntity.ok(response);
    }
}
