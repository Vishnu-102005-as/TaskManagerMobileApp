import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

class NotesProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  static const String _storageKey = 'local_notes';

  List<Note> get notes => List.unmodifiable(_notes);

  NotesProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _notes
        ..clear()
        ..addAll(decoded.map(
            (j) => Note.fromJson(j as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _storageKey, jsonEncode(_notes.map((n) => n.toJson()).toList()));
    } catch (_) {}
  }

  void addNote({required String title, required String content}) {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title.trim(),
      content: content.trim(),
      createdAt: DateTime.now(),
    );
    _notes.insert(0, note);
    _saveNotes();
    notifyListeners();
  }

  void updateNote(int id, {required String title, required String content}) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _notes[index] = _notes[index].copyWith(
      title: title.trim(),
      content: content.trim(),
    );
    _saveNotes();
    notifyListeners();
  }

  void deleteNote(int id) {
    _notes.removeWhere((n) => n.id == id);
    _saveNotes();
    notifyListeners();
  }
}
