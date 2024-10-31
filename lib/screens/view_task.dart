import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/providers/tasks.dart';
import 'package:todo_app/widgets/add_task.dart';
import 'package:intl/intl.dart';

class ViewTask extends ConsumerStatefulWidget {
  const ViewTask({super.key, required this.task});
  final Task task;

  @override
  ConsumerState<ViewTask> createState() {
    return _ViewTaskState();
  }
}

class _ViewTaskState extends ConsumerState<ViewTask> {
  bool isDueToday(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  bool isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final List<Task> tasks = ref.watch(tasksProvider);
    Task task = tasks.where((t) {
      return t.id == widget.task.id;
    }).toList()[0];

    final dueDate = task.dueDate;
    final theme = Theme.of(context);

    String displayDateTime;
    TextStyle dateTimeStyle;

    if (dueDate != null) {
      if (isDueToday(dueDate)) {
        displayDateTime = DateFormat.jm().format(dueDate);
      } else {
        displayDateTime = DateFormat.yMMMd().format(dueDate);
      }

      dateTimeStyle = isOverdue(dueDate)
          ? TextStyle(color: theme.colorScheme.error)
          : theme.textTheme.bodyLarge!;
    } else {
      displayDateTime = "No due date";
      dateTimeStyle = theme.textTheme.bodyLarge!;
    }

    updateTask() {
      final formKey = GlobalKey<FormState>();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return AddTask(
            formKey: formKey,
            task: task,
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("View Task"),
        actions: [
          IconButton(
            onPressed: updateTask,
            icon: const Icon(Icons.edit),
            color: theme.colorScheme.onSecondary,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              task.title,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),

            // Description
            Text(
              task.desc ?? "",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),

            // Categories
            Wrap(
              spacing: 8.0,
              children: task.categories
                  .map((category) => Chip(
                        backgroundColor: category.color,
                        label: Text(
                          category.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16.0),

            // Due Date
            Text(
              displayDateTime,
              style: dateTimeStyle,
            ),
            const SizedBox(height: 16.0),

            // Completion Status
            Row(
              children: [
                Icon(
                  task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: task.isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 8.0),
                Text(
                  task.isCompleted ? "Completed" : "Not Completed",
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
