package com.planitache.backend.dto;

import java.util.List;

public record AuthResponse(
    String token,
    String id,
    String username,
    String email,
    List<String> roles
) {}
