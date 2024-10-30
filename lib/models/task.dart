import 'package:todo_app/models/category.dart';

enum TaskType {
  nonRecurring,
  recurring,
}

class Task {
  const Task({
    required this.id,
    required this.title,
    this.type = TaskType.nonRecurring,
    this.dueDate,
    this.desc,
    this.isCompleted = false,
    this.categories = const [],
    this.repeatPattern = "",
    this.needReminder = false,
  });

  final int id;
  final String title;
  final String? desc;
  final TaskType type;
  final bool isCompleted;
  final DateTime? dueDate;
  final String? repeatPattern;
  final List<Category> categories;
  final bool needReminder;

  // Add the copyWith method
  Task copyWith({
    int? id,
    String? title,
    String? desc,
    TaskType? type,
    bool? isCompleted,
    DateTime? dueDate,
    String? repeatPattern,
    List<Category>? categories,
    bool? needReminder,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      repeatPattern: repeatPattern ?? this.repeatPattern,
      categories: categories ?? this.categories,
      needReminder: needReminder ?? this.needReminder,
    );
  }

  Map<String, dynamic> toMap() {
    final int typeInt = type == TaskType.recurring ? 1 : 0;
    final int completedInt = isCompleted ? 1 : 0;
    final int reminderInt = needReminder ? 1 : 0;

    return {
      "id": id,
      "title": title,
      "description": desc,
      "type": typeInt,
      "isCompleted": completedInt,
      "dueDate": dueDate != null ? dueDate!.millisecondsSinceEpoch : 0,
      "repeatPattern": repeatPattern,
      "categories": categories.map((category) => category.toMap()).toList(),
      "needReminder": reminderInt,
    };
  }

  static Task? fromMap(Map<String, dynamic> map) {
    if (!map.containsKey("id") || (map["id"] is! int) || !map.containsKey("title") || (map["title"] is! String)) {
      return null;
    }

    final taskType = map["type"] == 1 ? TaskType.recurring : TaskType.nonRecurring;

    return Task(
      id: map["id"],
      title: map["title"],
      desc: map["description"],
      type: taskType,
      isCompleted: map["isCompleted"] == 1,
      dueDate: map["dueDate"] != null ? DateTime.fromMillisecondsSinceEpoch(map["dueDate"]) : null,
      repeatPattern: map["repeatPattern"],
      categories: List<Category>.from(map["categories"].map((cat) => Category.fromMap(cat))),
      needReminder: map["needReminder"] == 1,
    );
  }
}
