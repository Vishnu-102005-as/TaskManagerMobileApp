import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/streak_task.dart';

class StreakProvider extends ChangeNotifier {
  final List<StreakTask> _tasks = [];
  static const String _storageKey = 'streak_tasks';
  Timer? _midnightTimer;

  List<StreakTask> get tasks => List.unmodifiable(_tasks);

  StreakProvider() {
    _loadAndProcess();
    _scheduleMidnightReset();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAndProcess() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        final stored = decoded
            .map((j) => StreakTask.fromJson(j as Map<String, dynamic>))
            .toList();
        _tasks
          ..clear()
          ..addAll(stored);
      }
      _processStreakReset();
      notifyListeners();
    } catch (_) {}
  }
  void _processStreakReset() {
    final today = _dateOnly(DateTime.now());
    for (int i = 0; i < _tasks.length; i++) {
      final t = _tasks[i];
      if (t.lastCompletedDate == null) continue;
      final lastDate = _dateOnly(t.lastCompletedDate!);
      if (lastDate == today) continue;
      final yesterday = today.subtract(const Duration(days: 1));
      if (lastDate == yesterday) {
        _tasks[i] = t.copyWith(completedToday: false);
      } else {
        _tasks[i] = t.copyWith(completedToday: false, streak: 0);
      }
    }
    _saveTasks();
  }

  void _scheduleMidnightReset() {
    final now = DateTime.now();
    final nextMidnight =
        DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    final durationUntilMidnight = nextMidnight.difference(now);

    _midnightTimer = Timer(durationUntilMidnight, () {
      _processStreakReset();
      _scheduleMidnightReset();
    });
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _storageKey, jsonEncode(_tasks.map((t) => t.toJson()).toList()));
    } catch (_) {}
  }

  void addStreakTask(String title) {
    final task = StreakTask(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title.trim(),
    );
    _tasks.insert(0, task);
    _saveTasks();
    notifyListeners();
  }

  void toggleStreakTask(int id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final task = _tasks[index];
    if (task.completedToday) return;

    _tasks[index] = task.copyWith(
      completedToday: true,
      streak: task.streak + 1,
      lastCompletedDate: DateTime.now(),
    );
    _saveTasks();
    notifyListeners();
  }

  void deleteStreakTask(int id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }
}
