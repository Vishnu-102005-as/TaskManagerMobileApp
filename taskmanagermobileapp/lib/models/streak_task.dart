class StreakTask {
  final int id;
  final String title;
  final int streak;
  final bool completedToday;
  final DateTime? lastCompletedDate;

  const StreakTask({
    required this.id,
    required this.title,
    this.streak = 0,
    this.completedToday = false,
    this.lastCompletedDate,
  });

  factory StreakTask.fromJson(Map<String, dynamic> json) {
    return StreakTask(
      id: json['id'] as int,
      title: json['title'] as String,
      streak: json['streak'] as int,
      completedToday: json['completedToday'] as bool,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'streak': streak,
        'completedToday': completedToday,
        'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      };

  StreakTask copyWith({
    String? title,
    int? streak,
    bool? completedToday,
    Object? lastCompletedDate = _unset,
  }) {
    return StreakTask(
      id: id,
      title: title ?? this.title,
      streak: streak ?? this.streak,
      completedToday: completedToday ?? this.completedToday,
      lastCompletedDate: lastCompletedDate == _unset
          ? this.lastCompletedDate
          : lastCompletedDate as DateTime?,
    );
  }
}

const Object _unset = Object();
