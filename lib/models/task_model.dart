class Task {
  int? id;
  int userId;
  String title;
  String? description;
  String dueDate;
  String priority;
  int isCompleted;
  int isFavorite;

  Task({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = 0,
    this.isFavorite = 0,
  });

  // For saving to local SQLite (snake_case)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'priority': priority,
      'is_completed': isCompleted,
      'is_favorite': isFavorite,
    };
  }

  // For sending TO your API (camelCase)
  Map<String, dynamic> toApiMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority.toLowerCase(), // MySQL stores lowercase
      'userId': userId,
      'isCompleted': isCompleted,
      'isFavourite': isFavorite,
    };
  }

  // For reading FROM SQLite (snake_case)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['due_date'],
      priority: (map['priority'] as String).capitalize(),
      isCompleted: map['is_completed'] ?? 0,
      isFavorite: map['is_favorite'] ?? 0,
    );
  }

  // For reading FROM your API response (camelCase)
  factory Task.fromApiMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      dueDate: (map['dueDate'] as String).split('T')[0], // trim timezone
      priority: (map['priority'] as String).capitalize(), // "low" → "Low"
      isCompleted: map['isCompleted'] ?? 0,
      isFavorite: map['isFavourite'] ?? 0,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}