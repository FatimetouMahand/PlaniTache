import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    fetchTasks(date: date);
  }

  // Récupérer les tâches du backend avec des filtres
  Future<void> fetchTasks({DateTime? date, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String queryParams = '?page=0&size=100&sortBy=time&sortDir=asc';
      if (date != null) {
        final dateStr = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        queryParams += '&date=$dateStr';
      }
      if (search != null && search.isNotEmpty) {
        queryParams += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await ApiClient.get('/tasks$queryParams');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final List content = data['content'] ?? [];
        _tasks = content.map((t) => Task.fromJson(t)).toList();
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Impossible de charger les tâches.';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau lors de la récupération des tâches.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter une tâche
  Future<bool> addTask(Task task) async {
    try {
      final response = await ApiClient.post('/tasks', task.toJson());
      if (response.statusCode == 201) {
        final newTask = Task.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        
        // Insérer ou recharger les tâches s'il s'agit de la date actuellement sélectionnée
        if (newTask.date.year == _selectedDate.year &&
            newTask.date.month == _selectedDate.month &&
            newTask.date.day == _selectedDate.day) {
          _tasks.add(newTask);
          _tasks.sort((a, b) => (a.time ?? '').compareTo(b.time ?? ''));
        }
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Mettre à jour une tâche
  Future<bool> updateTask(Task task) async {
    if (task.id == null) return false;
    try {
      final response = await ApiClient.put('/tasks/${task.id}', task.toJson());
      if (response.statusCode == 200) {
        final updatedTask = Task.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        } else {
          // Si la date a changé et qu'elle n'est plus dans le jour sélectionné
          fetchTasks(date: _selectedDate);
        }
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Activer/Désactiver la complétion
  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(
      completed: !task.completed,
      progressPercentage: !task.completed ? 100.0 : 0.0,
      satisfactionIndex: !task.completed ? 4 : null, // Mettre un index par défaut (4/5) lors de la complétion
    );
    await updateTask(updatedTask);
  }

  // Supprimer une tâche
  Future<bool> deleteTask(String id) async {
    try {
      final response = await ApiClient.delete('/tasks/$id');
      if (response.statusCode == 200) {
        _tasks.removeWhere((t) => t.id == id);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Ajouter un commentaire (TaskNote)
  Future<bool> addTaskNote(String taskId, String content) async {
    try {
      final response = await ApiClient.post('/tasks/$taskId/notes', {'content': content});
      if (response.statusCode == 200) {
        final updatedTask = Task.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        final index = _tasks.indexWhere((t) => t.id == taskId);
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Supprimer un commentaire
  Future<bool> deleteTaskNote(String taskId, String noteId) async {
    try {
      final response = await ApiClient.delete('/tasks/$taskId/notes/$noteId');
      if (response.statusCode == 200) {
        final updatedTask = Task.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        final index = _tasks.indexWhere((t) => t.id == taskId);
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Analyser le texte dicté vocalement via l'API NLP du backend
  Future<Task?> parseVoiceCommand(String text) async {
    try {
      final response = await ApiClient.post('/voice/parse', {'text': text});
      if (response.statusCode == 200) {
        final rawDto = jsonDecode(utf8.decode(response.bodyBytes));
        return Task.fromJson(rawDto);
      }
    } catch (_) {}
    return null;
  }
}
