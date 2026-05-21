package com.planitache.backend.dto;

import java.util.Map;

public class StatsResponse {
    private long completedCount;
    private long pendingCount;
    private double completionRate;
    private double averageSatisfaction;
    private Map<String, Long> categoryBreakdown;
    private Map<String, Long> priorityBreakdown;
    private Map<String, Double> weeklyProductivity; // Date -> taux de complétion (%)
    private Map<String, Double> monthlyProductivity; // Mois -> taux de complétion (%)

    public StatsResponse() {
    }

    public StatsResponse(long completedCount, long pendingCount, double completionRate, double averageSatisfaction,
                         Map<String, Long> categoryBreakdown, Map<String, Long> priorityBreakdown,
                         Map<String, Double> weeklyProductivity, Map<String, Double> monthlyProductivity) {
        this.completedCount = completedCount;
        this.pendingCount = pendingCount;
        this.completionRate = completionRate;
        this.averageSatisfaction = averageSatisfaction;
        this.categoryBreakdown = categoryBreakdown;
        this.priorityBreakdown = priorityBreakdown;
        this.weeklyProductivity = weeklyProductivity;
        this.monthlyProductivity = monthlyProductivity;
    }

    // Getters and Setters
    public long getCompletedCount() {
        return completedCount;
    }

    public void setCompletedCount(long completedCount) {
        this.completedCount = completedCount;
    }

    public long getPendingCount() {
        return pendingCount;
    }

    public void setPendingCount(long pendingCount) {
        this.pendingCount = pendingCount;
    }

    public double getCompletionRate() {
        return completionRate;
    }

    public void setCompletionRate(double completionRate) {
        this.completionRate = completionRate;
    }

    public double getAverageSatisfaction() {
        return averageSatisfaction;
    }

    public void setAverageSatisfaction(double averageSatisfaction) {
        this.averageSatisfaction = averageSatisfaction;
    }

    public Map<String, Long> getCategoryBreakdown() {
        return categoryBreakdown;
    }

    public void setCategoryBreakdown(Map<String, Long> categoryBreakdown) {
        this.categoryBreakdown = categoryBreakdown;
    }

    public Map<String, Long> getPriorityBreakdown() {
        return priorityBreakdown;
    }

    public void setPriorityBreakdown(Map<String, Long> priorityBreakdown) {
        this.priorityBreakdown = priorityBreakdown;
    }

    public Map<String, Double> getWeeklyProductivity() {
        return weeklyProductivity;
    }

    public void setWeeklyProductivity(Map<String, Double> weeklyProductivity) {
        this.weeklyProductivity = weeklyProductivity;
    }

    public Map<String, Double> getMonthlyProductivity() {
        return monthlyProductivity;
    }

    public void setMonthlyProductivity(Map<String, Double> monthlyProductivity) {
        this.monthlyProductivity = monthlyProductivity;
    }
}
