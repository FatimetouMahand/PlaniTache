package com.planitache.backend.controller;

import com.planitache.backend.dto.TaskDto;
import com.planitache.backend.service.VoiceParsingService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/voice")
public class VoiceController {

    private final VoiceParsingService voiceParsingService;

    public VoiceController(VoiceParsingService voiceParsingService) {
        this.voiceParsingService = voiceParsingService;
    }

    @PostMapping("/parse")
    public ResponseEntity<TaskDto> parseVoiceText(@RequestBody Map<String, String> request) {
        String text = request.get("text");
        TaskDto taskDto = voiceParsingService.parseVoiceText(text);
        return ResponseEntity.ok(taskDto);
    }
}
