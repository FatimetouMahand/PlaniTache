package com.planitache.backend.dto;

import jakarta.validation.constraints.NotBlank;

public record AuthRequest(
    @NotBlank(message = "Le nom d'utilisateur ou l'email est requis")
    String usernameOrEmail,
    
    @NotBlank(message = "Le mot de passe est requis")
    String password
) {}
