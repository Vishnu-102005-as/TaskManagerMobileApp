import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  static const String _storageKey = 'local_tasks';

  List<Task> get tasks => List.unmodifiable(_tasks);

  int get completedCount => _tasks.where((t) => t.completed).length;
  int get uncompletedCount => _tasks.where((t) => !t.completed).length;
  double get completionRatio {
    final total = _tasks.length;
    if (total == 0) return 0;
    return completedCount / total;
  }

  TaskProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final stored = decoded
          .map((j) => Task.fromJson(j as Map<String, dynamic>))
          .toList();
      _tasks
        ..clear()
        ..addAll(stored);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  void addTask({
    required String title,
    String description = '',
    String? imagePath,
  }) {
    final newTask = Task(
      id: -DateTime.now().millisecondsSinceEpoch,
      title: title.trim(),
      description: description.trim(),
      completed: false,
      createdAt: DateTime.now(),
      imagePath: imagePath,
    );
    _tasks.insert(0, newTask);
    _saveTasks();
    notifyListeners();
  }

  void toggleTask(int id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final task = _tasks[index];
    final nowCompleted = !task.completed;
    _tasks[index] = task.copyWith(
      completed: nowCompleted,
      completedAt: nowCompleted ? DateTime.now() : null,
    );
    _saveTasks();
    notifyListeners();
  }

  void deleteTask(int id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  void restoreTask(Task task) {
    _tasks.insert(0, task);
    _saveTasks();
    notifyListeners();
  }
}