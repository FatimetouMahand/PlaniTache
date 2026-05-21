package com.planitache.backend.service;

import com.planitache.backend.dto.StatsResponse;
import com.planitache.backend.entity.Task;
import com.planitache.backend.repository.TaskRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class StatisticsService {

    private final TaskRepository taskRepository;

    public StatisticsService(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    public StatsResponse getUserStats(String userId) {
        List<Task> allTasks = taskRepository.findByUserId(userId);
        
        if (allTasks.isEmpty()) {
            return new StatsResponse(0, 0, 0.0, 0.0, 
                    new HashMap<>(), new HashMap<>(), 
                    new LinkedHashMap<>(), new LinkedHashMap<>());
        }

        // Tâches terminées vs en cours
        long completedCount = allTasks.stream().filter(Task::isCompleted).count();
        long pendingCount = allTasks.size() - completedCount;
        double completionRate = ((double) completedCount / allTasks.size()) * 100.0;

        // Calcul de la satisfaction moyenne (sur les tâches terminées ayant une note de satisfaction renseignée)
        double averageSatisfaction = allTasks.stream()
                .filter(Task::isCompleted)
                .filter(t -> t.getSatisfactionIndex() != null)
                .mapToInt(Task::getSatisfactionIndex)
                .average()
                .orElse(0.0);

        // Répartition par catégorie
        Map<String, Long> categoryBreakdown = allTasks.stream()
                .collect(Collectors.groupingBy(t -> t.getCategory().name(), Collectors.counting()));

        // Répartition par priorité
        Map<String, Long> priorityBreakdown = allTasks.stream()
                .collect(Collectors.groupingBy(t -> t.getPriority().name(), Collectors.counting()));

        // Productivité Hebdomadaire (7 derniers jours)
        Map<String, Double> weeklyProductivity = new LinkedHashMap<>();
        LocalDate today = LocalDate.now();
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        
        for (int i = 6; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            String dateStr = date.format(dateFormatter);
            
            List<Task> dayTasks = allTasks.stream()
                    .filter(t -> t.getDate() != null && t.getDate().equals(date))
                    .collect(Collectors.toList());
            
            if (dayTasks.isEmpty()) {
                weeklyProductivity.put(dateStr, 0.0);
            } else {
                long done = dayTasks.stream().filter(Task::isCompleted).count();
                double rate = ((double) done / dayTasks.size()) * 100.0;
                weeklyProductivity.put(dateStr, rate);
            }
        }

        // Productivité Mensuelle (6 derniers mois)
        Map<String, Double> monthlyProductivity = new LinkedHashMap<>();
        DateTimeFormatter monthFormatter = DateTimeFormatter.ofPattern("yyyy-MM");
        
        for (int i = 5; i >= 0; i--) {
            LocalDate monthDate = today.minusMonths(i);
            String monthStr = monthDate.format(monthFormatter);
            
            List<Task> monthTasks = allTasks.stream()
                    .filter(t -> t.getDate() != null && t.getDate().getYear() == monthDate.getYear() 
                            && t.getDate().getMonth() == monthDate.getMonth())
                    .collect(Collectors.toList());
            
            if (monthTasks.isEmpty()) {
                monthlyProductivity.put(monthStr, 0.0);
            } else {
                long done = monthTasks.stream().filter(Task::isCompleted).count();
                double rate = ((double) done / monthTasks.size()) * 100.0;
                monthlyProductivity.put(monthStr, rate);
            }
        }

        return new StatsResponse(
                completedCount,
                pendingCount,
                completionRate,
                averageSatisfaction,
                categoryBreakdown,
                priorityBreakdown,
                weeklyProductivity,
                monthlyProductivity
        );
    }
}
