package com.planitache.backend.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Document(collection = "tasks")
public class Task {
    @Id
    private String id;

    @Indexed
    private String userId;

    private String title;
    private String description;
    private TaskCategory category;
    private TaskPriority priority;
    private LocalDate date;
    private LocalTime time;
    
    private boolean completed = false;
    private double progressPercentage = 0.0;
    
    private List<TaskNote> notes = new ArrayList<>();
    
    private String voiceNotePath;
    private Integer satisfactionIndex; // 1-5, optionnel pour évaluer la satisfaction de réalisation

    private Instant createdAt = Instant.now();
    private Instant updatedAt = Instant.now();

    public Task() {
    }

    public Task(String userId, String title, String description, TaskCategory category, TaskPriority priority, LocalDate date, LocalTime time) {
        this.userId = userId;
        this.title = title;
        this.description = description;
        this.category = category;
        this.priority = priority;
        this.date = date;
        this.time = time;
        this.completed = false;
        this.progressPercentage = 0.0;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    // Classe interne pour les notes/commentaires associés à une tâche
    public static class TaskNote {
        private String id;
        private String content;
        private Instant createdAt;

        public TaskNote() {
            this.id = UUID.randomUUID().toString();
            this.createdAt = Instant.now();
        }

        public TaskNote(String content) {
            this.id = UUID.randomUUID().toString();
            this.content = content;
            this.createdAt = Instant.now();
        }

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }

        public Instant getCreatedAt() {
            return createdAt;
        }

        public void setCreatedAt(Instant createdAt) {
            this.createdAt = createdAt;
        }
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public TaskCategory getCategory() {
        return category;
    }

    public void setCategory(TaskCategory category) {
        this.category = category;
    }

    public TaskPriority getPriority() {
        return priority;
    }

    public void setPriority(TaskPriority priority) {
        this.priority = priority;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public String getVoiceNotePath() {
        return voiceNotePath;
    }

    public void setVoiceNotePath(String voiceNotePath) {
        this.voiceNotePath = voiceNotePath;
    }

    public LocalTime getTime() {
        return time;
    }

    public void setTime(LocalTime time) {
        this.time = time;
    }

    public boolean isCompleted() {
        return completed;
    }

    public void setCompleted(boolean completed) {
        this.completed = completed;
    }

    public double getProgressPercentage() {
        return progressPercentage;
    }

    public void setProgressPercentage(double progressPercentage) {
        this.progressPercentage = progressPercentage;
    }

    public List<TaskNote> getNotes() {
        return notes;
    }

    public void setNotes(List<TaskNote> notes) {
        this.notes = notes;
    }

    public Integer getSatisfactionIndex() {
        return satisfactionIndex;
    }

    public void setSatisfactionIndex(Integer satisfactionIndex) {
        this.satisfactionIndex = satisfactionIndex;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }
}
