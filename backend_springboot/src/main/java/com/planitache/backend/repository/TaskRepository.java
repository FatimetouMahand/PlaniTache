package com.planitache.backend.repository;

import com.planitache.backend.entity.Task;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface TaskRepository extends MongoRepository<Task, String> {
    List<Task> findByUserId(String userId);
    List<Task> findByUserIdAndDate(String userId, LocalDate date);
    List<Task> findByUserIdAndCompleted(String userId, boolean completed);
    List<Task> findByUserIdAndDateBetween(String userId, LocalDate start, LocalDate end);
}
