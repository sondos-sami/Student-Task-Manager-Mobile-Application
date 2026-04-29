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

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['due_date'],
      priority: map['priority'],
      isCompleted: map['is_completed'],
      isFavorite: map['is_favorite'],
    );
  }
}