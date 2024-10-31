import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/models/category.dart' as cat_model;
import 'package:flutter/material.dart';

class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier(this.supabase) : super([]);

  final SupabaseClient supabase;

  Future<Task?> addTask(Map<String, dynamic> task) async {
  final String uid = supabase.auth.currentUser!.id;
  task["user_id"] = uid;

  // Extract categories and remove from the task map
  final List<cat_model.Category>? categories = task["categories"];
  task.remove("categories");

  // Convert due date to ISO format if it exists
  if (task["dueDate"] != null && task["dueDate"] is DateTime) {
    task["dueDate"] = task["dueDate"].toIso8601String();
  }

  // Insert task into the tasks table
  final response = await supabase.from('tasks').insert([task]).select();
  final List<dynamic> data = response;

  if (data.isNotEmpty) {
    final taskJson = data[0];

    // Insert task-category mappings into task_categories table
    if (categories != null && categories.isNotEmpty) {
      for (var category in categories) {
        await supabase.from('task_categories').insert({
          "task_id": taskJson["id"],
          "category_id": category.id,
          "user_id": uid,
        });
      }
    }

    // Create Task object from response with associated categories
    final newTask = Task(
      id: taskJson["id"],
      title: taskJson["title"],
      desc: taskJson["description"],
      dueDate: taskJson["dueDate"] != null
          ? DateTime.parse(taskJson["dueDate"])
          : null,
      isCompleted: false,
      categories: categories ?? [], // Add the list of categories here
    );

    // Update state with new task
    state = [newTask, ...state];
    return newTask;
  }

  return null;
}


  Future<bool> updateTask(Task task, Map<String, dynamic> updates) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      if (updates["dueDate"] != null && updates["dueDate"] is DateTime) {
        updates["dueDate"] = updates["dueDate"].toIso8601String();
      }
      final List<cat_model.Category>? categories = updates["categories"];
      updates.remove("categories");

      final response = await supabase
          .from('tasks')
          .update(updates)
          .eq('id', task.id)
          .select();

      if (response.isEmpty) {
        return false;
      }

      final updatedTaskJson = response[0];
      final updatedTask = Task(
        id: updatedTaskJson["id"],
        title: updatedTaskJson["title"],
        desc: updatedTaskJson["description"],
        dueDate: updatedTaskJson["dueDate"] != null
            ? DateTime.parse(updatedTaskJson["dueDate"])
            : null,
        isCompleted: updatedTaskJson["isCompleted"] ?? false,
      );

      // Update task categories if present in updates
      if (categories != null) {
        final List<cat_model.Category> updatedCategories =
            categories;
        // Clear existing categories for this task
        await supabase.from('task_categories').delete().eq("task_id", task.id);

        // Insert updated categories
        for (var category in updatedCategories) {
          await supabase.from('task_categories').insert({
            "task_id": task.id,
            "category_id": category.id,
            "user_id": user.id,
          });
        }
      }

      state = state.map((t) => t.id == task.id ? updatedTask : t).toList();

      return true;
    } catch (e) {
      debugPrint('Error updating task: $e');
      return false;
    }
  }

  Future<List<Task>?> fetchTasks() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return [];
    }
    final String uid = user.id;

    try {
      // Select tasks with joined task_categories and category data
      final response = await supabase
          .from('tasks')
          .select('*, task_categories (category:categories (*))')
          .eq('user_id', uid);
      final List<dynamic>? tasks = response as List<dynamic>?;
      if (tasks == null || tasks.isEmpty) {
        return [];
      }

      final List<Task> res = [];
      for (var taskJson in tasks) {
        final taskId = taskJson["id"];

        // Retrieve categories associated with the task
        final categoriesResponse =
            taskJson["task_categories"] as List<dynamic>? ?? [];
        final List<cat_model.Category> categories =
            categoriesResponse.map((categoryJson) {
          final category = categoryJson["category"];
          return cat_model.Category(
            id: category["id"],
            name: category["name"],
            color: Color(category["color"]),
            isFav: category["isFav"],
          );
        }).toList();
        // Create Task object with associated categories
        final task = Task(
          id: taskId,
          title: taskJson["title"],
          desc: taskJson["description"],
          dueDate: taskJson["dueDate"] != null
              ? DateTime.parse(taskJson["dueDate"])
              : null,
          isCompleted: taskJson["isCompleted"] ?? false,
          categories: categories,
        );
        res.add(task);
      }

      state = res.reversed.toList();
      return res.reversed.toList();
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      return [];
    }
  }

  Future<bool> deleteTask(Task task) async {
    try {
      await supabase.from('tasks').delete().eq('id', task.id);

      // Delete associated categories from task_categories
      await supabase.from('task_categories').delete().eq('task_id', task.id);

      state = state.where((t) => t.id != task.id).toList();

      return true;
    } catch (e) {
      return false;
    }
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final supabase = Supabase.instance.client;
  return TasksNotifier(supabase);
});
