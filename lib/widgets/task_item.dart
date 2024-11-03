import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/providers/tasks.dart';
import 'package:todo_app/screens/view_task.dart';

class TaskItem extends ConsumerWidget {
  const TaskItem({super.key, required this.task});

  final Task task;

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
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDate = task.dueDate;

    String displayDateTime;
    TextStyle dateTimeStyle;

    if (dueDate != null) {
      if (isDueToday(dueDate)) {
        displayDateTime = DateFormat.jm().format(dueDate);
      } else {
        displayDateTime = DateFormat.yMMMd().format(dueDate);
      }

      dateTimeStyle = isOverdue(dueDate)
          ? TextStyle(color: Theme.of(context).colorScheme.error)
          : TextStyle(color: Theme.of(context).colorScheme.onSurface);
    } else {
      displayDateTime = "No due date";
      dateTimeStyle = TextStyle(color: Theme.of(context).colorScheme.onSurface);
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return ViewTask(task: task);
            },
          ),
        );
      },
      child: Dismissible(
        direction: DismissDirection.horizontal,
        key: Key(task.id.toString()),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            ref.read(tasksProvider.notifier).deleteTask(task);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Task Deleted Successfully"),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: "Undo",
                  onPressed: () {
                    ref.read(tasksProvider.notifier).undoDelete();
                  },
                ),
              ),
            );
            return true;
          } else if (direction == DismissDirection.startToEnd) {
            ref
                .read(tasksProvider.notifier)
                .updateTask(task, {"isCompleted": !task.isCompleted});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(!task.isCompleted
                    ? "Task Completed Successfully"
                    : "Task Marked as Incomplete"),
                duration: const Duration(seconds: 3),
              ),
            );
            return false;
          }
          return false;
        },
        background: Container(
          color: !task.isCompleted
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context)
                  .colorScheme
                  .error, // Swipe right background
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: !task.isCompleted
              ? Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 30,
                )
              : Icon(
                  Icons.cancel_outlined,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 30,
                ),
        ),
        secondaryBackground: Container(
          color: Theme.of(context).colorScheme.error, // Swipe left background
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(
            Icons.delete,
            color: Theme.of(context).colorScheme.onError,
            size: 30,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: 60,
          width: double.infinity,
          child: Row(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: 30,
                  width: 20,
                  child: Checkbox(
                    shape: const CircleBorder(),
                    value: task.isCompleted,
                    onChanged: (newVal) {
                      ref
                          .read(tasksProvider.notifier)
                          .updateTask(task, {"isCompleted": newVal});
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          overflow: TextOverflow.ellipsis, fontSize: 20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayDateTime,
                          style: dateTimeStyle,
                        ),
                        Row(
                          children:
                              task.categories.asMap().entries.map((entry) {
                            return Text(
                              entry.key + 1 == task.categories.length
                                  ? entry.value.name
                                  : "${entry.value.name}, ",
                              style: Theme.of(context).textTheme.bodyMedium,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
