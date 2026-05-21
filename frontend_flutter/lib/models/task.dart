import 'dart:convert';

enum TaskCategory { STUDY, WORK, PERSONAL, HEALTH, SPORT, MEETINGS, OTHER }

enum TaskPriority { LOW, MEDIUM, HIGH }

class TaskNote {
  final String id;
  final String content;
  final DateTime createdAt;

  TaskNote({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  factory TaskNote.fromJson(Map<String, dynamic> json) {
    return TaskNote(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

class Task {
  final String? id;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime date;
  final String? time; // Format "HH:mm" ou null
  final bool completed;
  final double progressPercentage;
  final List<TaskNote> notes;
  final String? voiceNotePath;
  final int? satisfactionIndex;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.date,
    this.time,
    this.completed = false,
    this.progressPercentage = 0.0,
    this.notes = const [],
    this.voiceNotePath,
    this.satisfactionIndex,
  });

  // Pour parser le format "HH:mm:ss" ou "HH:mm" du backend
  static String? _parseTime(dynamic timeJson) {
    if (timeJson == null) return null;
    if (timeJson is String) {
      if (timeJson.length >= 5) {
        return timeJson.substring(0, 5); // Garde juste HH:mm
      }
      return timeJson;
    }
    return null;
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    // Parser Category
    TaskCategory category = TaskCategory.OTHER;
    try {
      category = TaskCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => TaskCategory.OTHER,
      );
    } catch (_) {}

    // Parser Priority
    TaskPriority priority = TaskPriority.MEDIUM;
    try {
      priority = TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => TaskPriority.MEDIUM,
      );
    } catch (_) {}

    // Parser Notes
    List<TaskNote> notes = [];
    if (json['notes'] != null) {
      notes = List<TaskNote>.from(
        (json['notes'] as List).map((n) => TaskNote.fromJson(n)),
      );
    }

    return Task(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: category,
      priority: priority,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      time: _parseTime(json['time']),
      completed: json['completed'] ?? false,
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      notes: notes,
      voiceNotePath: json['voiceNotePath'],
      satisfactionIndex: json['satisfactionIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      // Format YYYY-MM-DD
      'date': "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      if (time != null) 'time': time!.length == 5 ? "$time:00" : time, // S'assurer du format HH:mm:ss pour Jackson LocalTime
      'completed': completed,
      'progressPercentage': progressPercentage,
      if (voiceNotePath != null) 'voiceNotePath': voiceNotePath,
      if (satisfactionIndex != null) 'satisfactionIndex': satisfactionIndex,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? date,
    String? time,
    bool? completed,
    double? progressPercentage,
    List<TaskNote>? notes,
    String? voiceNotePath,
    int? satisfactionIndex,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      time: time ?? this.time,
      completed: completed ?? this.completed,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      notes: notes ?? this.notes,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
      satisfactionIndex: satisfactionIndex ?? this.satisfactionIndex,
    );
  }
}
