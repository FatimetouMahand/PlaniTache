import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/note.dart';

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> fetchNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.get('/notes');
      if (response.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(response.bodyBytes));
        _notes = list.map((n) => Note.fromJson(n)).toList();
      }
    } catch (_) {}
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addNote(String content) async {
    try {
      final response = await ApiClient.post('/notes', {'content': content});
      if (response.statusCode == 201) {
        final newNote = Note.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        _notes.insert(0, newNote);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> updateNote(String id, String content) async {
    try {
      final response = await ApiClient.put('/notes/$id', {'content': content});
      if (response.statusCode == 200) {
        final updated = Note.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        final index = _notes.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notes[index] = updated;
          notifyListeners();
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> deleteNote(String id) async {
    try {
      final response = await ApiClient.delete('/notes/$id');
      if (response.statusCode == 200) {
        _notes.removeWhere((n) => n.id == id);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }
}
