class Task {
  final int id;
  final String title;
  final String description;
  final bool completed;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? imagePath;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.completed,
    required this.createdAt,
    this.completedAt,
    this.imagePath,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      completed: json['completed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? createdAt,
    Object? completedAt = _unset,
    Object? imagePath = _unset,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      completedAt:
          completedAt == _unset ? this.completedAt : completedAt as DateTime?,
      imagePath:
          imagePath == _unset ? this.imagePath : imagePath as String?,
    );
  }
}

const Object _unset = Object();
