package com.planitache.backend.dto;

import jakarta.validation.constraints.NotBlank;

public record TaskNoteRequest(
    @NotBlank(message = "Le contenu du commentaire ne peut pas être vide")
    String content
) {}
