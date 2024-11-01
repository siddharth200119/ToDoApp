import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/providers/tasks.dart';
import 'package:todo_app/widgets/task_item.dart';

class TasksList extends ConsumerStatefulWidget {
  final int? categoryIdFilter;
  final DateTime? dueDateFilter;

  const TasksList({
    super.key,
    this.categoryIdFilter,
    this.dueDateFilter,
  });

  @override
  ConsumerState<TasksList> createState() {
    return _TasksListState();
  }
}

class _TasksListState extends ConsumerState<TasksList> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("No Tasks Added!"),
    );

    final List<Task> tasks = ref.watch(tasksProvider).where((task) {
      bool matchesCategory = widget.categoryIdFilter == null ||
          (task.categories.any((category) => category.id == widget.categoryIdFilter));

      bool matchesDueDate = widget.dueDateFilter == null ||
          (task.dueDate != null && task.dueDate!.isBefore(widget.dueDateFilter!) || task.dueDate == null);
      
      return matchesCategory && matchesDueDate;
    }).toList();

    // Separate and sort tasks
    final List<Task> completedTasks = tasks.where((task) => task.isCompleted).toList()
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });

    final List<Task> pendingTasks = tasks.where((task) => !task.isCompleted).toList()
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });

    if (tasks.isNotEmpty) {
      content = SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: pendingTasks.length,
              itemBuilder: (BuildContext context, int index) {
                return TaskItem(task: pendingTasks[index]);
              },
            ),
            const SizedBox(height: 16),
            ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _isExpanded = isExpanded;
                });
              },
              elevation: 1,
              children: [
                ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return const ListTile(
                      title: Text(
                        'Completed Tasks',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                  body: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    itemCount: completedTasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return TaskItem(task: completedTasks[index]);
                    },
                  ),
                  isExpanded: _isExpanded,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return content;
  }
}
