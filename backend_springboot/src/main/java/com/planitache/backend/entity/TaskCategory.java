package com.planitache.backend.entity;

public enum TaskCategory {
    STUDY("Études"),
    WORK("Travail"),
    PERSONAL("Personnel"),
    HEALTH("Santé"),
    SPORT("Sport"),
    MEETINGS("Réunions"),
    OTHER("Autre");

    private final String displayName;

    TaskCategory(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
