package com.planitache.backend.entity;

public enum TaskPriority {
    LOW("Basse"),
    MEDIUM("Moyenne"),
    HIGH("Haute");

    private final String displayName;

    TaskPriority(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
