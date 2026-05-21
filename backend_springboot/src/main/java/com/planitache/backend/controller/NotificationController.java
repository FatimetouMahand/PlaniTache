package com.planitache.backend.controller;

import com.planitache.backend.entity.Notification;
import com.planitache.backend.entity.User;
import com.planitache.backend.service.NotificationService;
import com.planitache.backend.service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;
    private final UserService userService;

    public NotificationController(NotificationService notificationService, UserService userService) {
        this.notificationService = notificationService;
        this.userService = userService;
    }

    private String getUserId(Principal principal) {
        User user = userService.findByUsername(principal.getName());
        return user.getId();
    }

    @GetMapping
    public ResponseEntity<List<Notification>> getUserNotifications(
            Principal principal,
            @RequestParam(defaultValue = "false") boolean unreadOnly) {
        String userId = getUserId(principal);
        List<Notification> notifications;
        if (unreadOnly) {
            notifications = notificationService.getUnreadNotifications(userId);
        } else {
            notifications = notificationService.getUserNotifications(userId);
        }
        return ResponseEntity.ok(notifications);
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<?> markAsRead(Principal principal, @PathVariable String id) {
        String userId = getUserId(principal);
        try {
            Notification notification = notificationService.markAsRead(userId, id);
            return ResponseEntity.ok(notification);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @PutMapping("/read-all")
    public ResponseEntity<?> markAllAsRead(Principal principal) {
        String userId = getUserId(principal);
        notificationService.markAllAsRead(userId);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Toutes les notifications ont été marquées comme lues.");
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteNotification(Principal principal, @PathVariable String id) {
        String userId = getUserId(principal);
        try {
            notificationService.deleteNotification(userId, id);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Notification supprimée avec succès");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }
}
