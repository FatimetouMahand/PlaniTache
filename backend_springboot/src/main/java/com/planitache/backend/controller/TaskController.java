package com.planitache.backend.controller;

import com.planitache.backend.dto.TaskDto;
import com.planitache.backend.dto.TaskNoteRequest;
import com.planitache.backend.entity.Task;
import com.planitache.backend.entity.TaskCategory;
import com.planitache.backend.entity.TaskPriority;
import com.planitache.backend.entity.User;
import com.planitache.backend.service.TaskService;
import com.planitache.backend.service.UserService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {

    private final TaskService taskService;
    private final UserService userService;

    public TaskController(TaskService taskService, UserService userService) {
        this.taskService = taskService;
        this.userService = userService;
    }

    private String getUserId(Principal principal) {
        User user = userService.findByUsername(principal.getName());
        return user.getId();
    }

    @GetMapping
    public ResponseEntity<?> getTasks(
            Principal principal,
            @RequestParam(required = false) TaskCategory category,
            @RequestParam(required = false) TaskPriority priority,
            @RequestParam(required = false) Boolean completed,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "date") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir) {
        
        String userId = getUserId(principal);
        Page<Task> tasks = taskService.getTasks(userId, category, priority, completed, date, search, page, size, sortBy, sortDir);
        
        Map<String, Object> response = new HashMap<>();
        response.put("content", tasks.getContent());
        response.put("currentPage", tasks.getNumber());
        response.put("totalItems", tasks.getTotalElements());
        response.put("totalPages", tasks.getTotalPages());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getTaskById(Principal principal, @PathVariable String id) {
        String userId = getUserId(principal);
        try {
            Task task = taskService.getTaskById(userId, id);
            return ResponseEntity.ok(taskService.convertToDto(task));
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.NOT_FOUND);
        }
    }

    @PostMapping
    public ResponseEntity<?> createTask(Principal principal, @Valid @RequestBody TaskDto taskDto) {
        String userId = getUserId(principal);
        Task task = taskService.createTask(userId, taskDto);
        return new ResponseEntity<>(taskService.convertToDto(task), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateTask(Principal principal, @PathVariable String id, @Valid @RequestBody TaskDto taskDto) {
        String userId = getUserId(principal);
        try {
            Task task = taskService.updateTask(userId, id, taskDto);
            return ResponseEntity.ok(taskService.convertToDto(task));
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTask(Principal principal, @PathVariable String id) {
        String userId = getUserId(principal);
        try {
            taskService.deleteTask(userId, id);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Tâche supprimée avec succès");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    // Gestion des commentaires (TaskNote) sur une tâche
    @PostMapping("/{id}/notes")
    public ResponseEntity<?> addTaskNote(Principal principal, @PathVariable String id, @Valid @RequestBody TaskNoteRequest request) {
        String userId = getUserId(principal);
        try {
            Task task = taskService.addTaskNote(userId, id, request.content());
            return ResponseEntity.ok(task);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/{id}/notes/{noteId}")
    public ResponseEntity<?> deleteTaskNote(Principal principal, @PathVariable String id, @PathVariable String noteId) {
        String userId = getUserId(principal);
        try {
            Task task = taskService.deleteTaskNote(userId, id, noteId);
            return ResponseEntity.ok(task);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }
}
