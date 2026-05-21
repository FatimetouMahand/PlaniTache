package com.planitache.backend.dto;

import com.planitache.backend.entity.TaskCategory;
import com.planitache.backend.entity.TaskPriority;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.LocalTime;

public record TaskDto(
    String id,
    
    @NotBlank(message = "Le titre est requis")
    String title,
    
    String description,
    
    @NotNull(message = "La catégorie est requise")
    TaskCategory category,
    
    @NotNull(message = "La priorité est requise")
    TaskPriority priority,
    
    @NotNull(message = "La date est requise")
    LocalDate date,
    
    LocalTime time,
    
    boolean completed,
    
    double progressPercentage,
    
    String voiceNotePath,
    
    Integer satisfactionIndex
) {}
