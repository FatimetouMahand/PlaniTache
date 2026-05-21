package com.planitache.backend.service;

import com.planitache.backend.dto.TaskDto;
import com.planitache.backend.entity.TaskCategory;
import com.planitache.backend.entity.TaskPriority;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.temporal.TemporalAdjusters;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class VoiceParsingService {

    public TaskDto parseVoiceText(String text) {
        if (text == null || text.trim().isEmpty()) {
            return new TaskDto(null, "Nouvelle tâche", "", TaskCategory.OTHER, TaskPriority.MEDIUM, LocalDate.now(), null, false, 0.0, null, null);
        }

        String cleanedText = text.toLowerCase().trim();
        
        // 1. Extraction de la Date
        LocalDate parsedDate = LocalDate.now();
        String datePhraseToRemove = "";
        
        if (cleanedText.contains("aujourd'hui")) {
            parsedDate = LocalDate.now();
            datePhraseToRemove = "aujourd'hui";
        } else if (cleanedText.contains("après-demain") || cleanedText.contains("apres-demain")) {
            parsedDate = LocalDate.now().plusDays(2);
            datePhraseToRemove = cleanedText.contains("après-demain") ? "après-demain" : "apres-demain";
        } else if (cleanedText.contains("demain")) {
            parsedDate = LocalDate.now().plusDays(1);
            datePhraseToRemove = "demain";
        } else {
            // Recherche de jours de la semaine : lundi, mardi, etc.
            String[] days = {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"};
            for (String day : days) {
                if (cleanedText.contains(day)) {
                    parsedDate = getNextOccurrence(day);
                    datePhraseToRemove = day;
                    break;
                }
            }
        }

        // 2. Extraction de l'Heure (Ex: "à 8h", "à 14h30", "à 15 heures", "à 9 heures 15")
        LocalTime parsedTime = null;
        String timePhraseToRemove = "";
        
        // Regex pour attraper les formats comme "8h", "14h30", "8h30", "12h00"
        Pattern timePattern1 = Pattern.compile("(?:à|a)\\s*(\\d{1,2})\\s*[hH]\\s*(\\d{0,2})");
        Matcher matcher1 = timePattern1.matcher(cleanedText);
        
        if (matcher1.find()) {
            int hour = Integer.parseInt(matcher1.group(1));
            int minute = 0;
            if (matcher1.group(2) != null && !matcher1.group(2).trim().isEmpty()) {
                minute = Integer.parseInt(matcher1.group(2));
            }
            if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
                parsedTime = LocalTime.of(hour, minute);
                timePhraseToRemove = matcher1.group(0);
            }
        } else {
            // Regex pour "à X heures"
            Pattern timePattern2 = Pattern.compile("(?:à|a)\\s*(\\d{1,2})\\s*heures?");
            Matcher matcher2 = timePattern2.matcher(cleanedText);
            if (matcher2.find()) {
                int hour = Integer.parseInt(matcher2.group(1));
                if (hour >= 0 && hour < 24) {
                    parsedTime = LocalTime.of(hour, 0);
                    timePhraseToRemove = matcher2.group(0);
                }
            }
        }

        // 3. Déduction de la Catégorie
        TaskCategory category = TaskCategory.OTHER;
        if (containsAny(cleanedText, "étudier", "etudier", "réviser", "reviser", "cours", "examen", "devoir", "projet", "spring boot", "flutter")) {
            category = TaskCategory.STUDY;
        } else if (containsAny(cleanedText, "travail", "bureau", "work", "client", "boss", "professionnel", "pro")) {
            category = TaskCategory.WORK;
        } else if (containsAny(cleanedText, "sport", "jogging", "entraînement", "entrainement", "courir", "foot", "muscu", "vélo", "gym")) {
            category = TaskCategory.SPORT;
        } else if (containsAny(cleanedText, "santé", "sante", "médecin", "medecin", "dentiste", "médicament", "pharma", "docteur")) {
            category = TaskCategory.HEALTH;
        } else if (containsAny(cleanedText, "réunion", "reunion", "meeting", "call", "entretien", "conférence")) {
            category = TaskCategory.MEETINGS;
        } else if (containsAny(cleanedText, "courses", "acheter", "ménage", "menage", "famille", "ami", "cinéma", "cinema", "resto", "perso")) {
            category = TaskCategory.PERSONAL;
        }

        // 4. Déduction de la Priorité
        TaskPriority priority = TaskPriority.MEDIUM;
        if (containsAny(cleanedText, "urgent", "important", "prioritaire", "vite", "absolument")) {
            priority = TaskPriority.HIGH;
        } else if (containsAny(cleanedText, "faible", "tranquille", "pas pressé", "basse")) {
            priority = TaskPriority.LOW;
        }

        // 5. Nettoyage du Titre (Retirer les expressions de date et d'heure pour garder l'action principale)
        String title = text;
        if (!datePhraseToRemove.isEmpty()) {
            title = replaceIgnoreCase(title, datePhraseToRemove, "");
        }
        if (!timePhraseToRemove.isEmpty()) {
            title = replaceIgnoreCase(title, timePhraseToRemove, "");
        }
        
        // Nettoyer les liaisons inutiles comme "à", "de", "le", "la" en début de phrase restante
        title = title.replaceAll("(?i)\\b(à|a|pour|le|la|les|de|du|en)\\b", "").trim();
        title = title.replaceAll("\\s+", " ").trim();
        
        if (title.isEmpty()) {
            title = "Tâche vocale";
        } else {
            // Capitaliser la première lettre
            title = title.substring(0, 1).toUpperCase() + title.substring(1);
        }

        return new TaskDto(
                null,
                title,
                "Créé automatiquement par commande vocale : \"" + text + "\"",
                category,
                priority,
                parsedDate,
                parsedTime,
                false,
                0.0,
                null,
                null
        );
    }

    private LocalDate getNextOccurrence(String dayName) {
        DayOfWeek targetDay;
        switch (dayName.toLowerCase()) {
            case "lundi": targetDay = DayOfWeek.MONDAY; break;
            case "mardi": targetDay = DayOfWeek.TUESDAY; break;
            case "mercredi": targetDay = DayOfWeek.WEDNESDAY; break;
            case "jeudi": targetDay = DayOfWeek.THURSDAY; break;
            case "vendredi": targetDay = DayOfWeek.FRIDAY; break;
            case "samedi": targetDay = DayOfWeek.SATURDAY; break;
            case "dimanche": targetDay = DayOfWeek.SUNDAY; break;
            default: return LocalDate.now();
        }
        LocalDate date = LocalDate.now();
        if (date.getDayOfWeek() == targetDay) {
            return date.plusWeeks(1); // Lundi prochain
        }
        return date.with(TemporalAdjusters.next(targetDay));
    }

    private boolean containsAny(String text, String... keywords) {
        for (String keyword : keywords) {
            if (text.contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    private String replaceIgnoreCase(String target, String regex, String replacement) {
        return Pattern.compile(regex, Pattern.CASE_INSENSITIVE).matcher(target).replaceAll(replacement);
    }
}
