package com.planitache.backend.controller;

import com.planitache.backend.dto.StatsResponse;
import com.planitache.backend.entity.User;
import com.planitache.backend.service.StatisticsService;
import com.planitache.backend.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

@RestController
@RequestMapping("/api/statistics")
public class StatisticsController {

    private final StatisticsService statisticsService;
    private final UserService userService;

    public StatisticsController(StatisticsService statisticsService, UserService userService) {
        this.statisticsService = statisticsService;
        this.userService = userService;
    }

    @GetMapping
    public ResponseEntity<StatsResponse> getUserStats(Principal principal) {
        User user = userService.findByUsername(principal.getName());
        StatsResponse stats = statisticsService.getUserStats(user.getId());
        return ResponseEntity.ok(stats);
    }
}
