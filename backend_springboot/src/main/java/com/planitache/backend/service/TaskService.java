package com.planitache.backend.service;

import com.planitache.backend.dto.TaskDto;
import com.planitache.backend.entity.Task;
import com.planitache.backend.entity.TaskCategory;
import com.planitache.backend.entity.TaskPriority;
import com.planitache.backend.exception.ResourceNotFoundException;
import com.planitache.backend.repository.TaskRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class TaskService {

    private final TaskRepository taskRepository;
    private final MongoTemplate mongoTemplate;

    public TaskService(TaskRepository taskRepository, MongoTemplate mongoTemplate) {
        this.taskRepository = taskRepository;
        this.mongoTemplate = mongoTemplate;
    }

    public Task createTask(String userId, TaskDto taskDto) {
        Task task = new Task(
                userId,
                taskDto.title(),
                taskDto.description(),
                taskDto.category(),
                taskDto.priority(),
                taskDto.date(),
                taskDto.time()
        );
        task.setVoiceNotePath(taskDto.voiceNotePath());
        task.setSatisfactionIndex(taskDto.satisfactionIndex());
        if (taskDto.completed()) {
            task.setCompleted(true);
            task.setProgressPercentage(100.0);
        } else {
            task.setProgressPercentage(taskDto.progressPercentage());
        }
        return taskRepository.save(task);
    }

    public Task updateTask(String userId, String taskId, TaskDto taskDto) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Tâche non trouvée avec l'id : " + taskId));

        if (!task.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Vous n'êtes pas autorisé à modifier cette tâche.");
        }

        task.setTitle(taskDto.title());
        task.setDescription(taskDto.description());
        task.setCategory(taskDto.category());
        task.setPriority(taskDto.priority());
        task.setDate(taskDto.date());
        task.setTime(taskDto.time());
        task.setCompleted(taskDto.completed());
        task.setProgressPercentage(taskDto.completed() ? 100.0 : taskDto.progressPercentage());
        task.setVoiceNotePath(taskDto.voiceNotePath());
        task.setSatisfactionIndex(taskDto.satisfactionIndex());
        task.setUpdatedAt(Instant.now());

        return taskRepository.save(task);
    }

    public void deleteTask(String userId, String taskId) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Tâche non trouvée avec l'id : " + taskId));

        if (!task.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Vous n'êtes pas autorisé à supprimer cette tâche.");
        }

        taskRepository.delete(task);
    }

    public Task getTaskById(String userId, String taskId) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Tâche non trouvée avec l'id : " + taskId));

        if (!task.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Vous n'êtes pas autorisé à voir cette tâche.");
        }

        return task;
    }

    // Filtrage, recherche, tri et pagination dynamiques avec MongoTemplate
    public Page<Task> getTasks(String userId, TaskCategory category, TaskPriority priority, 
                               Boolean completed, LocalDate date, String search,
                               int page, int size, String sortBy, String sortDir) {
        
        Query query = new Query();
        
        // Filtre obligatoire sur l'utilisateur
        query.addCriteria(Criteria.where("userId").is(userId));
        
        // Filtres optionnels
        if (category != null) {
            query.addCriteria(Criteria.where("category").is(category));
        }
        if (priority != null) {
            query.addCriteria(Criteria.where("priority").is(priority));
        }
        if (completed != null) {
            query.addCriteria(Criteria.where("completed").is(completed));
        }
        if (date != null) {
            query.addCriteria(Criteria.where("date").is(date));
        }
        if (search != null && !search.trim().isEmpty()) {
            query.addCriteria(new Criteria().orOperator(
                    Criteria.where("title").regex(search, "i"),
                    Criteria.where("description").regex(search, "i")
            ));
        }
        
        // Comptage total avant pagination
        long total = mongoTemplate.count(query, Task.class);
        
        // Tri
        Sort.Direction direction = Sort.Direction.fromString(sortDir.equalsIgnoreCase("desc") ? "DESC" : "ASC");
        query.with(Sort.by(direction, sortBy));
        
        // Pagination
        query.with(PageRequest.of(page, size));
        
        List<Task> tasks = mongoTemplate.find(query, Task.class);
        
        return new PageImpl<>(tasks, PageRequest.of(page, size), total);
    }

    // Ajouter un commentaire/note à une tâche
    public Task addTaskNote(String userId, String taskId, String content) {
        Task task = getTaskById(userId, taskId);
        task.getNotes().add(new Task.TaskNote(content));
        task.setUpdatedAt(Instant.now());
        return taskRepository.save(task);
    }

    // Supprimer un commentaire d'une tâche
    public Task deleteTaskNote(String userId, String taskId, String noteId) {
        Task task = getTaskById(userId, taskId);
        boolean removed = task.getNotes().removeIf(n -> n.getId().equals(noteId));
        if (!removed) {
            throw new ResourceNotFoundException("Commentaire non trouvé avec l'id : " + noteId);
        }
        task.setUpdatedAt(Instant.now());
        return taskRepository.save(task);
    }

    public TaskDto convertToDto(Task task) {
        return new TaskDto(
                task.getId(),
                task.getTitle(),
                task.getDescription(),
                task.getCategory(),
                task.getPriority(),
                task.getDate(),
                task.getTime(),
                task.isCompleted(),
                task.getProgressPercentage(),
                task.getVoiceNotePath(),
                task.getSatisfactionIndex()
        );
    }
}
