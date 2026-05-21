package com.planitache.backend.service;

import com.planitache.backend.dto.NoteDto;
import com.planitache.backend.entity.Note;
import com.planitache.backend.exception.ResourceNotFoundException;
import com.planitache.backend.repository.NoteRepository;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

@Service
public class NoteService {

    private final NoteRepository noteRepository;

    public NoteService(NoteRepository noteRepository) {
        this.noteRepository = noteRepository;
    }

    public Note createNote(String userId, NoteDto noteDto) {
        Note note = new Note(userId, noteDto.content());
        return noteRepository.save(note);
    }

    public Note updateNote(String userId, String noteId, NoteDto noteDto) {
        Note note = noteRepository.findById(noteId)
                .orElseThrow(() -> new ResourceNotFoundException("Note non trouvée avec l'id : " + noteId));

        if (!note.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Vous n'êtes pas autorisé à modifier cette note.");
        }

        note.setContent(noteDto.content());
        return noteRepository.save(note);
    }

    public void deleteNote(String userId, String noteId) {
        Note note = noteRepository.findById(noteId)
                .orElseThrow(() -> new ResourceNotFoundException("Note non trouvée avec l'id : " + noteId));

        if (!note.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Vous n'êtes pas autorisé à supprimer cette note.");
        }

        noteRepository.delete(note);
    }

    public List<Note> getUserNotes(String userId) {
        return noteRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }
}
