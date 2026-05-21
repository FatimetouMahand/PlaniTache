package com.planitache.backend.dto;

import jakarta.validation.constraints.NotBlank;

public record NoteDto(
    String id,
    @NotBlank(message = "Le contenu de la note ne peut pas être vide")
    String content
) {}
