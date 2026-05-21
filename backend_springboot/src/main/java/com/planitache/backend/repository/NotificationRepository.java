package com.planitache.backend.repository;

import com.planitache.backend.entity.Notification;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends MongoRepository<Notification, String> {
    List<Notification> findByUserId(String userId);
    List<Notification> findByUserIdAndRead(String userId, boolean read);
    List<Notification> findByUserIdOrderByCreatedAtDesc(String userId);
}
