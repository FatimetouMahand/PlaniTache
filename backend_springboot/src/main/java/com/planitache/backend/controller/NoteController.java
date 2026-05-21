package com.planitache.backend.controller;

import com.planitache.backend.dto.NoteDto;
import com.planitache.backend.entity.Note;
import com.planitache.backend.entity.User;
import com.planitache.backend.service.NoteService;
import com.planitache.backend.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notes")
public class NoteController {

    private final NoteService noteService;
    private final UserService userService;

    public NoteController(NoteService noteService, UserService userService) {
        this.noteService = noteService;
        this.userService = userService;
    }

    private String getUserId(Principal principal) {
        User user = userService.findByUsername(principal.getName());
        return user.getId();
    }

    @GetMapping
    public ResponseEntity<List<Note>> getUserNotes(Principal principal) {
        String userId = getUserId(principal);
        List<Note> notes = noteService.getUserNotes(userId);
        return ResponseEntity.ok(notes);
    }

    @PostMapping
    public ResponseEntity<Note> createNote(Principal principal, @Valid @RequestBody NoteDto noteDto) {
        String userId = getUserId(principal);
        Note note = noteService.createNote(userId, noteDto);
        return new ResponseEntity<>(note, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateNote(Principal principal, @PathVariable String id, @Valid @RequestBody NoteDto noteDto) {
        String userId = getUserId(principal);
        try {
            Note note = noteService.updateNote(userId, id, noteDto);
            return ResponseEntity.ok(note);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteNote(Principal principal, @PathVariable String id) {
        String userId = getUserId(principal);
        try {
            noteService.deleteNote(userId, id);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Note supprimée avec succès");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }
}
