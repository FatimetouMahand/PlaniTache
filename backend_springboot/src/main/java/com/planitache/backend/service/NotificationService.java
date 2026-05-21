package com.planitache.backend.service;

import com.planitache.backend.entity.Notification;
import com.planitache.backend.exception.ResourceNotFoundException;
import com.planitache.backend.repository.NotificationRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;

    public NotificationService(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    public Notification createNotification(String userId, String message) {
        Notification notification = new Notification(userId, message);
        return notificationRepository.save(notification);
    }

    public List<Notification> getUserNotifications(String userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public List<Notification> getUnreadNotifications(String userId) {
        return notificationRepository.findByUserIdAndRead(userId, false);
    }

    public Notification markAsRead(String userId, String notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification non trouvée avec l'id : " + notificationId));

        if (!notification.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Vous n'êtes pas autorisé à modifier cette notification.");
        }

        notification.setRead(true);
        return notificationRepository.save(notification);
    }

    public void markAllAsRead(String userId) {
        List<Notification> unread = notificationRepository.findByUserIdAndRead(userId, false);
        for (Notification notification : unread) {
            notification.setRead(true);
        }
        notificationRepository.saveAll(unread);
    }

    public void deleteNotification(String userId, String notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification non trouvée avec l'id : " + notificationId));

        if (!notification.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Vous n'êtes pas autorisé à supprimer cette notification.");
        }

        notificationRepository.delete(notification);
    }
}
